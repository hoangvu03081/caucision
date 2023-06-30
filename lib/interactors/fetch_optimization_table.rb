module Interactors
  class FetchOptimizationTable < BaseInteractor
    include Dependency['select']

    def call(params, user)
      campaign = Campaign.find_by(id: params[:id], user_id: user.id)
      return Failure(Errors::NotFoundError.build(Campaign, params[:id])) unless campaign
      return Failure(not_optimized_error(params[:id])) unless campaign.optimized?

      dataframe = yield select.call(table_name: campaign.data_id)
      optimization_result = MessagePack.unpack(campaign.optimization_result)

      framed_optimization_result = Polars::DataFrame.new(
        Polars::Series.new('Best promotion', optimization_result)
      )

      dataframe = dataframe.hstack(framed_optimization_result)

      filtered_dataframe = Polars::QueryExtension.query(
        dataframe,
        filter_by: params[:filter],
        sort_by: params[:sort]
      )

      Success(filtered_dataframe)
    end

    private

      def not_optimized_error(campaign_id)
        Errors::InvalidParamsError.new(
          "Campaign #{campaign_id} is not optimized"
        )
      end
  end
end
