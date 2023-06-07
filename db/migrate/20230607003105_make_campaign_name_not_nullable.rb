class MakeCampaignNameNotNullable < ActiveRecord::Migration[7.0]
  def change
    change_column_null :campaigns, :name, false
  end
end
