class AddCampaignsTable < ActiveRecord::Migration[7.0]
  def change
    create_table :campaigns, id: :uuid do |t|
      t.boolean     :data_imported, null: false, default: false
      t.references  :project, index: true, type: :uuid

      t.timestamps
    end
  end
end
