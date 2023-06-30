class Campaign < ApplicationRecord
  include PgSearch::Model

  belongs_to :user
  belongs_to :project
  has_many :graphs

  multisearchable against: [:name],
                  additional_attributes: ->(campaign) { { user_id: campaign.user_id } }

  def data_id
    "c_#{id.underscore}_data"
  end

  def ordered_graphs
    graphs.sort_by do |graph|
      graph_order.index(graph.id)
    end
  end

  def optimized?
    optimization_result.present?
  end
end
