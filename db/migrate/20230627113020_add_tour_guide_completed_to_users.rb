class AddTourGuideCompletedToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :tour_guide_completed, :boolean, default: false, null: false
  end
end
