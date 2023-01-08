# frozen_string_literal: true

class Report < ApplicationRecord
  LINK_MATCHER = %r{http://localhost:3000/reports/([1-9]+[0-9]*)}

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

  def including_mention?
    content.match?(LINK_MATCHER)
  end

  def save_mentioning_reports
    mentioning_reports_in_content.each { |mentioning_report| mentioning_reports << mentioning_report }
  end

  def update_mentioning_reports
    active_mentioning.each(&:destroy!)
    save_mentioning_reports
  end

  def created_on
    created_at.to_date
  end

  private

  def mentioning_reports_in_content
    content.scan(LINK_MATCHER).flatten.each_with_object([]) do |report_id, reports|
      report = Report.find_by(id: report_id)
      reports.push(report) unless reports.include?(report) || report.nil?
    end
  end
end
