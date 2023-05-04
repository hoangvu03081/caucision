class AddGraphs < ActiveRecord::Migration[7.0]
  def change
    create_table :graphs, id: :uuid do |t|
      t.jsonb :data, null: false, default: {}

      t.references  :project, index: true, type: :uuid
      t.references  :campaign, index: true, type: :uuid

      t.timestamps
    end

    add_column :projects, :graph_order, :text, array: true, default: []
    add_column :campaigns, :graph_order, :text, array: true, default: []
  end
end
