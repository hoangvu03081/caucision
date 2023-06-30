module CaucisionMl
  URL = ENV['CAUCISION_ML_URL'].freeze

  class << self
    def save_campaign_data(campaign_data_id:, project_id:, file:)
      endpoint = URI(URL).merge('/campaign_data')

      HTTP.post(endpoint, form: { file:, campaign_data_id:, project_id: })
    end

    def optimize(campaign_id:, promotion_costs:, budget:)
      endpoint = URI(URL).merge('/optimize')

      HTTP.post(endpoint, json: { campaign_id:, promotion_costs:, budget: })
    end
  end
end
