# frozen_string_literal: true

require 'test_helper'

class ReportTest < ActiveSupport::TestCase
  setup do
    @report = FactoryBot.create(:report)
    @other_report_url = "http://localhost:3000/reports/#{FactoryBot.create(:report).id}"
    @unsaved_report = FactoryBot.build(:report)
  end

  test "should not count up MentioningMentionedReport when report does not mention other report's url" do
    assert_difference 'MentioningMentionedReport.count', 0 do
      @report.save_report_and_mentionings
    end
  end

  test "should count up MentioningMentionedReport when report mentions other report's url" do
    @unsaved_report.content += @other_report_url
    assert_difference 'MentioningMentionedReport.count', 1 do
      @unsaved_report.save_report_and_mentionings
    end
  end

  test "should count up MentioningMentionedReport once when report mentions another report's url twice" do
    @unsaved_report.content += (@other_report_url * 2)
    assert_difference 'MentioningMentionedReport.count', 1 do
      @unsaved_report.save_report_and_mentionings
    end
  end

  test "should count up twice MentioningMentionedReport when report mentions multiple report's url" do
    some_report = FactoryBot.create(:report)
    @unsaved_report.content += @other_report_url + "http://localhost:3000/reports/#{some_report.id}"
    assert_difference 'MentioningMentionedReport.count', 2 do
      @unsaved_report.save_report_and_mentionings
    end
  end

  test "should count up MentioningMentionedReport when report is updated with content mentioning other report's url" do
    assert_difference 'MentioningMentionedReport.count', 1 do
      @report.assign_attributes(content: @other_report_url)
      @report.save_report_and_mentionings
    end
  end

  test "should count down MentioningMentionedReport when report is updated without content mentioning other report's url" do
    @report.assign_attributes(content: @other_report_url)
    @report.save_report_and_mentionings
    assert_difference 'MentioningMentionedReport.count', -1 do
      @report.assign_attributes(content: 'test')
      @report.save_report_and_mentionings
    end
  end

  test 'should not count up MentioningMentionedReport when report is updated with same content' do
    @report.assign_attributes(content: @other_report_url)
    @report.save_report_and_mentionings
    assert_difference 'MentioningMentionedReport.count', 0 do
      @report.assign_attributes(title: 'test')
      @report.save_report_and_mentionings
    end
  end
end
