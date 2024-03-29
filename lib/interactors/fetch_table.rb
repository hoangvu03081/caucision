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

      predicted_columns = infer_predicted_columns(record) if model == Campaign

      if predicted_columns
        filtered_dataframe = Polars::QueryExtension.round(
          filtered_dataframe,
          columns: predicted_columns,
          precision: 3
        )

        sorted_columns = Set['user_id', *predicted_columns, *filtered_dataframe.columns]

        filtered_dataframe = filtered_dataframe.select(sorted_columns)
      end

      Success([filtered_dataframe, { predicted_columns: }])
    end

    private

      def infer_predicted_columns(record)
        project = record.project

        promotions = project.promotions.reject do |promotion|
          promotion == project.control_promotion
        end

        promotions.reduce([]) do |result, promotion|
          result + ["#{promotion} conversion", "#{promotion} outcome"]
        end
      end
  end
end
