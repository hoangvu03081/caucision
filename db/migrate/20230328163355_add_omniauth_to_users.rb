class AddOmniauthToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :provider, :text, null: false
  end
end
