module CaucisionMl
  URL = ENV['CAUCISION_ML_URL'].freeze

  class << self
    def save_campaign_data(campaign_data_id:, project_id:, file:)
      endpoint = URI(URL).merge('/campaign_data')

      HTTP.post(
        endpoint,
        form: {
          file:,
          campaign_data_id:,
          project_id:
        }
      )
    end
  end
end
