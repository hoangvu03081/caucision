class AddDefaultToTimestamp < ActiveRecord::Migration[7.0]
  def change
    change_column_default :campaigns, :created_at, -> { 'CURRENT_TIMESTAMP' }
    change_column_default :campaigns, :updated_at, -> { 'CURRENT_TIMESTAMP' }
    change_column_default :projects, :created_at, -> { 'CURRENT_TIMESTAMP' }
    change_column_default :projects, :updated_at, -> { 'CURRENT_TIMESTAMP' }
  end
end
