class AddDataSchemaToProjects < ActiveRecord::Migration[7.0]
  def change
    add_column :projects, :data_schema, :jsonb, null: false, default: {}
  end
end
