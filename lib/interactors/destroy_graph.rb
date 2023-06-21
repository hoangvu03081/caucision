module Interactors
  class DestroyGraph < BaseInteractor
    def call(params, _user)
      # TODO: Add find_by user_id here
      graph = Graph.find_by(id: params[:id])
      return Failure(Errors::NotFoundError.build(Graph, params[:id])) unless graph

      record = graph.owner
      graph.destroy!

      new_graph_order = record.graph_order.tap { |order| order.delete(graph.id) }
      record.update!(graph_order: new_graph_order)

      Success()
    end
  end
end
