class Project < ApplicationRecord
  belongs_to :user
  has_many :campaigns

  def data_id
    "p_#{id.underscore}_data"
  end
end
