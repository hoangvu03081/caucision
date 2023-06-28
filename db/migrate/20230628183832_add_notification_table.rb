class AddNotificationTable < ActiveRecord::Migration[7.0]
  def change
    create_table :notifications, id: :uuid do |t|
      t.text        :message, null: false
      t.text        :message_type, null: false
      t.jsonb       :metadata, null: false, default: {}
      t.boolean     :viewed, null: false, default: false
      t.references  :user, index: true, type: :uuid

      t.timestamps
    end
  end
end
