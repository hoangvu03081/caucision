class AddDataSchemaToCampaigns < ActiveRecord::Migration[7.0]
  def change
    add_column :campaigns, :data_schema, :jsonb, null: false, default: {}
  end
end
