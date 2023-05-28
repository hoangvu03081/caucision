class AddUserIdToCampaigns < ActiveRecord::Migration[7.0]
  def change
    add_reference :campaigns, :user, index: true, foreign_key: true, type: :uuid
  end
end
