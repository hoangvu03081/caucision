module Interactors
  class CreateOptimization < BaseInteractor
    def call(params, user)
      if params[:file].nil? && params[:promotion_costs].nil?
        return Failure(missing_params_error)
      end

      campaign = Campaign.find_by(id: params[:id], user_id: user.id)
      return Failure(Errors::NotFoundError.build(Campaign, params[:id])) unless campaign
      return Failure(optimization_existed_error(params[:id])) if campaign.optimized?

      promotion_costs = get_promotion_costs(params)
      promotions = campaign.project.promotions

      missing_promotions = promotions - promotion_costs.keys
      unless missing_promotions.empty?
        return Failure(missing_promotions_error(missing_promotions))
      end

      response = ::CaucisionMl.optimize(
        campaign_id: campaign.id,
        promotion_costs:,
        budget: params[:budget]
      )

      # TODO: Add proper error handling here
      return Failure(Errors::InternalError.new) unless response.status.success?

      response_body = JSON.parse(response.body)
      campaign.update!(optimization_result: MessagePack.pack(response_body))

      Success()
    end

    private

      def get_promotion_costs(params)
        return params[:promotion_costs] if params[:promotion_costs]

        dataframe = Polars.read_csv(params[:file], ignore_errors: true)
        dataframe.rows(named: true).to_h { |row| [row['promotion'], row['cost']] }
      end

      def missing_params_error
        Errors::InvalidParamsError.new(
          'Neither file nor promotion_costs is provided'
        )
      end

      def missing_promotions_error(promotions)
        Errors::InvalidParamsError.new(
          "#{promotions.join(', ')} are missing"
        )
      end

      def optimization_existed_error(campaign_id)
        Errors::InvalidParamsError.new(
          "Campaign #{campaign_id} has existing optimization"
        )
      end
  end
end
