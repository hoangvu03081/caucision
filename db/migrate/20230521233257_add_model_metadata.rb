class AddModelMetadata < ActiveRecord::Migration[7.0]
  def change
    add_column :projects, :promotions, :text, array: true, default: []
    add_column :projects, :model, :bytea, null: true
  end
end
