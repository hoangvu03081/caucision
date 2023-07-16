module Interactors
  class FetchOptimizationTable < BaseInteractor
    include Dependency['select']

    BEST_PROMOTION_COLUMN = 'Best promotion'.freeze

    def call(params, user)
      campaign = Campaign.find_by(id: params[:id], user_id: user.id)
      return Failure(Errors::NotFoundError.build(Campaign, params[:id])) unless campaign
      return Failure(not_optimized_error(params[:id])) unless campaign.optimized?

      dataframe = yield select.call(table_name: campaign.data_id)
      optimization_result = MessagePack.unpack(campaign.optimization_result)

      optimization_result_series = Polars::Series.new(BEST_PROMOTION_COLUMN, optimization_result)

      dataframe = dataframe.insert_at_idx(1, optimization_result_series)

      filtered_dataframe = Polars::QueryExtension.query(
        dataframe,
        filter_by: params[:filter],
        sort_by: params[:sort]
      )

      predicted_columns = infer_predicted_columns(campaign)
      filtered_dataframe = Polars::QueryExtension.round(
        filtered_dataframe,
        columns: predicted_columns,
        precision: 3
      )
      sorted_columns = Set['user_id', BEST_PROMOTION_COLUMN, *predicted_columns, *filtered_dataframe.columns]

      filtered_dataframe = filtered_dataframe.select(sorted_columns)
      predicted_columns << BEST_PROMOTION_COLUMN

      Success([filtered_dataframe, { predicted_columns: }])
    end

    private

      def not_optimized_error(campaign_id)
        Errors::InvalidParamsError.new(
          "Campaign #{campaign_id} is not optimized"
        )
      end

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
