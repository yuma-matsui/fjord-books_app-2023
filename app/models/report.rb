# frozen_string_literal: true

class Report < ApplicationRecord
  LINK_MATCHER = %r{http://localhost:3000/reports/([1-9]+\d*)}

  belongs_to :user
  has_many :comments, as: :commentable, dependent: :destroy

  validates :title, presence: true
  validates :content, presence: true

  def editable?(target_user)
    user == target_user
  end

  def including_mention?
    content.match?(LINK_MATCHER)
  end

  def mention
    content.scan(LINK_MATCHER).flatten.each_with_object([]) do |report_id, reports|
      report = Report.find_by(id: report_id)
      reports.push(report) unless reports.include?(report) || report.nil?
    end
  end

  def created_on
    created_at.to_date
  end
end
