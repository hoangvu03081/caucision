class AddProjectsTable < ActiveRecord::Migration[7.0]
  def change
    create_table :projects, id: :uuid do |t|
      t.text :name, null: false
      t.text :description

      t.timestamps
    end

    add_reference :projects, :user, foreign_key: true, type: :uuid
  end
end
