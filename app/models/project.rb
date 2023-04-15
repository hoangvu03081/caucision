class Project < ApplicationRecord
  belongs_to :user

  def data_id
    "p_#{id.underscore}_data"
  end
end
