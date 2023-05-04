class Project < ApplicationRecord
  belongs_to :user
  has_many :campaigns
  has_many :graphs

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
