class ProjectSerializer < ActiveModel::Serializer
  attributes :id, :name, :description,
             :created_at, :updated_at,
             :data_imported, :model_trained,
             :control_promotion, :graph_imported

  def graph_imported
    !!object.causal_graph
  end
end
