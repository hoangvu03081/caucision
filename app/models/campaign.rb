class Campaign < ApplicationRecord
  include PgSearch::Model

  belongs_to :project
  has_many :graphs

  multisearchable against: [:name],
                  additional_attributes: ->(campaign) { { user_id: campaign.user_id } }

  def data_id
    "c_#{id.underscore}_data"
  end
end
