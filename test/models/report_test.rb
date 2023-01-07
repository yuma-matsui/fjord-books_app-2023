# frozen_string_literal: true

require 'test_helper'

class ReportTest < ActiveSupport::TestCase
  setup do
    @report = FactoryBot.create(:report)
    @other_report = FactoryBot.create(:report)
    @base_url = 'http://localhost:3000/reports'
  end

  test "should return false when content does not include other report's url" do
    @report.content = "this report does not include report's url"
    assert_not @report.including_mention?
  end

  test "should return false when content includes other site's url" do
    @report.content = 'https://google.com'
    assert_not @report.including_mention?
  end

  test "should return true when content includes other report's url" do
    @report.content += "#{@base_url}/10"
    assert @report.including_mention?
  end

  test "should return an Array including other report when content includes other report's url" do
    @report.content += "#{@base_url}/#{@other_report.id}"
    assert_includes @report.mention, @other_report
  end

  test "should return an Array including other reports when content includes some report's url" do
    @some_report = FactoryBot.create(:report)
    @report.content += "#{@base_url}/#{@other_report.id},#{@base_url}/#{@some_report.id}"
    assert_includes @report.mention, @other_report
    assert_includes @report.mention, @some_report
  end

  test "should not return an Array including same reports when content includes same report's url" do
    other_report_url = "#{@base_url}/#{@other_report.id}"
    @report.content += (other_report_url * 2)
    assert_equal @report.mention.size, 1
  end

  test "should not return an Array including report when content includes unexisting report's url" do
    @report.content += "#{@base_url}/0"
    assert_equal @report.mention.size, 0
  end

  test 'should count up MentioningMentionedReport when report mentions other report' do
    assert_difference 'MentioningMentionedReport.count', 1 do
      @report.add_mention(@other_report)
    end
  end

  test "should count down MentioningMentionedReport when content remove other report's url" do
    @report.add_mention(@other_report)
    assert_difference 'MentioningMentionedReport.count', -1 do
      @report.remove_mention(@other_report)
    end
  end

  test 'should count down MentioningMentionedReport when mentioning report is destroyed' do
    @report.add_mention(@other_report)
    assert_difference 'MentioningMentionedReport.count', -1 do
      @report.destroy!
    end
  end

  test 'should count down MentioningMentionedReport when mentioned report is destroyed' do
    @report.add_mention(@other_report)
    assert_difference 'MentioningMentionedReport.count', -1 do
      @other_report.destroy!
    end
  end
end
