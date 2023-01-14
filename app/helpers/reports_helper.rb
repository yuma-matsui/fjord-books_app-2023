# frozen_string_literal: true

module ReportsHelper
  def change_to_link(text)
    text.gsub(%r{https?://[\w/.:-\\+%&_-][^<>]+}) { |url| tag.a(url, href: url) }
  end
end
