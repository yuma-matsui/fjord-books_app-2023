# frozen_string_literal: true

require 'test_helper'

class ReportTest < ActiveSupport::TestCase
  setup do
    @report = FactoryBot.create(:report)
    @base_url = 'http://localhost:3000/reports'
    @other_report_url = "#{@base_url}/#{FactoryBot.create(:report).id}"
    @unsaved_report = FactoryBot.build(:report)
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
    @report.content += @other_report_url
    assert @report.including_mention?
  end

  test "should not count up MentioningMentionedReport when report does not mention other report's url" do
    assert_difference 'MentioningMentionedReport.count', 0 do
      @report.save_mentioning_reports
    end
  end

  test "should count up MentioningMentionedReport when report mentions other report's url" do
    @unsaved_report.content += @other_report_url
    assert_difference 'MentioningMentionedReport.count', 1 do
      @unsaved_report.save
      @unsaved_report.save_mentioning_reports
    end
  end

  test "should count up MentioningMentionedReport once when report mentions another report's url twice" do
    @unsaved_report.content += (@other_report_url * 2)
    assert_difference 'MentioningMentionedReport.count', 1 do
      @unsaved_report.save
      @unsaved_report.save_mentioning_reports
    end
  end

  test "should not count up MentioningMentionedReport when report mentions unexisting report's url" do
    @unsaved_report.content += "#{@base_url}/0"
    assert_difference 'MentioningMentionedReport.count', 0 do
      @unsaved_report.save
      @unsaved_report.save_mentioning_reports
    end
  end

  test "should count up twice MentioningMentionedReport when report mentions multiple report's url" do
    some_report = FactoryBot.create(:report)
    @unsaved_report.content += @other_report_url + "#{@base_url}/#{some_report.id}"
    assert_difference 'MentioningMentionedReport.count', 2 do
      @unsaved_report.save
      @unsaved_report.save_mentioning_reports
    end
  end

  test "should count up MentioningMentionedReport when report is updated with content mentioning other report's url" do
    assert_difference 'MentioningMentionedReport.count', 1 do
      @report.update(content: @other_report_url)
      @report.update_mentioning_reports
    end
  end

  test "should count down MentioningMentionedReport when report is updated without content mentioning other report's url" do
    @report.update(content: @other_report_url)
    @report.update_mentioning_reports
    assert_difference 'MentioningMentionedReport.count', -1 do
      @report.update(content: 'test')
      @report.update_mentioning_reports
    end
  end

  test 'should not count up MentioningMentionedReport when report is updated with same content' do
    @report.update(content: @other_report_url)
    @report.update_mentioning_reports
    assert_difference 'MentioningMentionedReport.count', 0 do
      @report.update(title: 'test')
      @report.update_mentioning_reports
    end
  end
end
