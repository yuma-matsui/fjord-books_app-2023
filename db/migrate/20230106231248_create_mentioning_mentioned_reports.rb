class CreateMentioningMentionedReports < ActiveRecord::Migration[7.0]
  def change
    create_table :mentioning_mentioned_reports do |t|
      t.integer :mentioning_report_id, null: false
      t.integer :mentioned_report_id, null: false

      t.timestamps
    end
    add_index :mentioning_mentioned_reports, :mentioning_report_id
    add_index :mentioning_mentioned_reports, :mentioned_report_id
    add_index :mentioning_mentioned_reports, [:mentioning_report_id, :mentioned_report_id], name: 'mentioning_mentioned_reports_index', unique: true
  end
end
