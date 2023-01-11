# frozen_string_literal: true

class Report < ApplicationRecord
  LINK_MATCHER = %r{http://localhost:3000/reports/(\d+)}

  belongs_to :user
  has_many :comments, as: :commentable, dependent: :destroy

  has_many :active_mentioning, class_name: 'MentioningMentionedReport',
                               foreign_key: 'mentioned_report_id',
                               inverse_of: :mentioned_report,
                               dependent: :destroy
  has_many :mentioning_reports, through: :active_mentioning, source: :mentioning_report

  has_many :passive_mentioning, class_name: 'MentioningMentionedReport',
                                foreign_key: 'mentioning_report_id',
                                inverse_of: :mentioning_report,
                                dependent: :destroy
  has_many :mentioned_reports, through: :passive_mentioning, source: :mentioned_report

  validates :title, presence: true
  validates :content, presence: true

  scope :latest_order, -> { order(created_at: :desc) }

  def editable?(target_user)
    user == target_user
  end

  def save_report_and_mentioning_reports
    transaction do
      save!
      save_mentioning_reports
    end
  rescue ActiveRecord::RecordInvalid => e
    raise ActiveRecord::Rollback if save_mentioning_reports_failed?(e)

    false
  end

  def update_report_and_mentioning_reports(report_params)
    transaction do
      update!(report_params)
      active_mentioning.each(&:destroy!)
      save_mentioning_reports
    end
  rescue ActiveRecord::RecordInvalid => e
    raise ActiveRecord::Rollback if save_mentioning_reports_failed?(e)

    false
  end

  def created_on
    created_at.to_date
  end

  private

  def save_mentioning_reports
    content
      .scan(LINK_MATCHER)
      .uniq
      .each do |report_id|
        report = Report.find_by(id: report_id)
        mentioning_reports << report if report
      end
  end

  def save_mentioning_reports_failed?(error)
    error.message == 'バリデーションに失敗しました: Mentioning reportはすでに存在します'
  end
end
