# frozen_string_literal: true

module ReportsHelper
  def mentioned?(report)
    report.mentioned_reports.presence
  end

  def mentioned_reports(report)
    report.mentioned_reports.latest_order
  end
end
