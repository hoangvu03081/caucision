class AddModelTypeToProject < ActiveRecord::Migration[7.0]
  def change
    add_column :projects, :model_type, :text, null: true
  end
end
