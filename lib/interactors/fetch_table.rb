module Interactors
  class FetchTable < BaseInteractor
    include Dependency['select']

    MODEL_MAPPINGS = {
      project: Project,
      campaign: Campaign
    }.freeze

    def call(params, user, from:)
      model = MODEL_MAPPINGS.fetch(from)

      record = model.find_by(id: params[:id], user_id: user.id)
      return Failure(Errors::NotFoundError.build(model, params[:id])) unless record

      dataframe = yield select.call(table_name: record.data_id)

      filtered_dataframe = Polars::QueryExtension.query(
        dataframe,
        filter_by: params[:filter],
        sort_by: params[:sort]
      )

      Success(filtered_dataframe)
    end
  end
end
