class AddUserInfo < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :name,       :text
    add_column :users, :first_name, :text
    add_column :users, :last_name,  :text
    add_column :users, :image,      :text
  end
end
