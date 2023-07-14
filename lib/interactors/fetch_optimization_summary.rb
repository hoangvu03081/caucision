module Interactors
  class FetchOptimizationSummary < BaseInteractor
    include Dependency['select']

    BEST_PROMOTION_COLUMN = 'Best promotion'.freeze

    def call(params, user)
      campaign = Campaign.find_by(id: params[:id], user_id: user.id)
      return Failure(Errors::NotFoundError.build(Campaign, params[:id])) unless campaign
      return Failure(not_optimized_error(params[:id])) unless campaign.optimized?

      unless campaign.optimization_summary
        dataframe = yield select.call(table_name: campaign.data_id)
        optimization_result = MessagePack.unpack(campaign.optimization_result)
        optimization_metadata = MessagePack.unpack(campaign.optimization_metadata)
        promotion_costs = optimization_metadata['promotion_costs']

        total_conversion_rate = 0
        total_cost = 0

        dataframe.rows(named: true).each.with_index do |row, i|
          promotion = optimization_result[i]
          next if promotion.nil?

          # TODO: Investigate missing optimization row
          total_conversion_rate += (row["#{promotion} conversion"] || 0)

          outcome = (row["#{promotion} outcome"] || 0)
          total_cost += (promotion_costs[promotion] - outcome)
        end

        optimization_result = optimization_result.map do |value|
          value.nil? ? 'Undecided' : value
        end

        framed_optimization_result = Polars::DataFrame.new(
          [Polars::Series.new(BEST_PROMOTION_COLUMN, optimization_result)]
        )

        promotion_graph = yield Interactors::GraphBuilder::Column.new.call(
          {
            query_details: {
              'group_by' => [BEST_PROMOTION_COLUMN],
              'aggregate' => [{ column: BEST_PROMOTION_COLUMN, operation: 'count' }]
            }
          },
          framed_optimization_result
        )

        optimization_summary = {
          total_conversion_rate: total_conversion_rate.round(2),
          total_cost: total_cost.round(2),
          promotion_graph:,
          **optimization_metadata
        }

        campaign.update!(optimization_summary:)
      end

      Success(campaign.optimization_summary)
    end

    private

      def not_optimized_error(campaign_id)
        Errors::InvalidParamsError.new(
          "Campaign #{campaign_id} is not optimized"
        )
      end
  end
end
