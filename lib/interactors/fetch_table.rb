module Interactors
  class FetchTable < BaseInteractor
    include Dependency['select']

    def call(params)
      # TODO: Add user_id for this find_by
      project = Project.find_by(id: params[:id])
      return Failure(Errors::NotFoundError.build(Project, params[:id])) unless project

      dataframe = yield select.call(table_name: project.data_id)

      filtered_dataframe = Polars::QueryExtension.query(
        dataframe,
        filter_by: params[:filter],
        sort_by: params[:sort]
      )

      Success(filtered_dataframe)
    end
  end
end
