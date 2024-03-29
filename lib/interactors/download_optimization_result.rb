module Interactors
  class DownloadOptimizationResult
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

      tempfile = Tempfile.new(['optimization_result', '.csv'], Rails.root.join('tmp'))

      dataframe.write_csv(tempfile)

      Success(tempfile)
    end

    private

      def not_optimized_error(campaign_id)
        Errors::InvalidParamsError.new(
          "Campaign #{campaign_id} is not optimized"
        )
      end
  end
end
