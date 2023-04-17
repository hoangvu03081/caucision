class AddInfoToProjects < ActiveRecord::Migration[7.0]
  def change
    add_column :projects, :model_trained, :bool, default: false, null: false

    add_column :projects, :control_promotion, :text, null: true
    add_column :projects, :causal_graph, :text, null: true
  end
end
