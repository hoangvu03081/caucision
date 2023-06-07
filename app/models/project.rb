class Project < ApplicationRecord
  include PgSearch::Model

  belongs_to :user
  has_many :campaigns
  has_many :graphs

  multisearchable against: [:name, :description],
                  additional_attributes: ->(project) { { user_id: project.user_id } }

  def data_id
    "p_#{id.underscore}_data"
  end

  def causal_graph_imported?
    !!causal_graph
  end

  def ordered_graphs
    graphs.sort_by do |graph|
      graph_order.index(graph.id)
    end
  end
end
