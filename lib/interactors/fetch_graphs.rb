module Interactors
  class FetchGraphs < BaseInteractor
    def call(params, user)
      id, model =
        if params[:project_id]
          [params[:project_id], Project]
        elsif params[:campaign_id]
          [params[:campaign_id], Campaign]
        else
          raise Errors::InternalError, 'Routing for fetching graph is incorrect'
        end

      record = model.find_by(id:, user_id: user.id)
      return Failure(Errors::NotFoundError.build(model, id)) unless record

      Success(record.ordered_graphs)
    end
  end
end
