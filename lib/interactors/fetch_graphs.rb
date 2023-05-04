module Interactors
  class FetchGraphs < BaseInteractor
    def call(params, user)
      project = Project.find_by(id: params[:project_id], user_id: user.id)
      return Failure(Errors::NotFoundError.build(Project, params[:project_id])) unless project

      Success(project.ordered_graphs)
    end
  end
end
