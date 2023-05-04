module Interactors
  class CreateGraph < BaseInteractor
    def call(params, user)
      project = Project.find_by(id: params[:project_id], user_id: user.id)
      return Failure(Errors::NotFoundError.build(Project, params[:project_id])) unless project

      # TODO: Add transaction here
      graph = Graph.create!(project_id: params[:project_id], data: params[:data])
      project.update!(graph_order: project.graph_order.append(graph.id))

      Success(graph)
    end
  end
end
