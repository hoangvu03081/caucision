class AddOptimizationMetadata < ActiveRecord::Migration[7.0]
  def change
    add_column :campaigns, :optimization_metadata, :bytea, null: true
    add_column :campaigns, :optimization_result, :bytea, null: true
  end
end
