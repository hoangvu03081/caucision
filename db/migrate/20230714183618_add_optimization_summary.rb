class AddOptimizationSummary < ActiveRecord::Migration[7.0]
  def change
    add_column :campaigns, :optimization_summary, :jsonb, null: true
  end
end
