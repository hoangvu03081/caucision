module Interactors
  class CreateGraph < BaseInteractor
    def call(params, user)
      id, model =
        if params[:project_id]
          [params[:project_id], Project]
        elsif params[:campaign_id]
          [params[:campaign_id], Campaign]
        else
          raise Errors::InternalError, 'Routing for creating graph is incorrect'
        end

      record = model.find_by(id:, user_id: user.id)
      return Failure(Errors::NotFoundError.build(model, id)) unless project

      # TODO: Add transaction here
      graph = Graph.create!(project_id: params[:project_id], data: params[:data])
      record.update!(graph_order: record.graph_order.append(graph.id))

      Success(graph)
    end
  end
end
