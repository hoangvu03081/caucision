class AddDataImportedToProjects < ActiveRecord::Migration[7.0]
  def change
    add_column :projects, :data_imported, :bool, default: false, null: false
  end
end
