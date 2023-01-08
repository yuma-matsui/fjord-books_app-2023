# frozen_string_literal: true

module ReportsHelper
  def mentioned?(report)
    report.mentioned_reports.presence
  end

  def mentioned_reports(report)
    report.mentioned_reports.latest_order
  end

  def format_mention(text)
    text.gsub(Report::LINK_MATCHER) do |url|
      target = Report.find_by(id: Regexp.last_match(1))
      target.nil? ? url : "<a href='#{url}'>#{url}</a>"
    end
  end
end
