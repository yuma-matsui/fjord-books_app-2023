# frozen_string_literal: true

module ReportsHelper
  def format_mention(text)
    text.gsub(Report::LINK_MATCHER) do |url|
      target = Report.find_by(id: Regexp.last_match(1))
      target.nil? ? url : tag.a(url, href: url)
    end
  end
end
