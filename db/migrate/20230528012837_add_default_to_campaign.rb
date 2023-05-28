class AddDefaultToCampaign < ActiveRecord::Migration[7.0]
  def change
    add_column :campaigns, :name, :text, null: true
    add_column :campaigns, :default, :boolean, null: false, default: false

    add_index :campaigns, :name
    add_index :projects, :name
    add_index :projects, :description
  end
end
