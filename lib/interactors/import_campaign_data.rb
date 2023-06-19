module Interactors
  class ImportCampaignData < BaseInteractor
    BLACKLISTED_COLUMNS = %w(promotion outcome).freeze

    def call(params, user)
      campaign = Campaign.find_by(id: params[:id], user_id: user.id)
      return Failure(Errors::NotFoundError.build(Campaign, params[:id])) unless campaign

      dataframe = Polars.read_csv(params[:file], ignore_errors: true)

      if dataframe.schema.keys.intersect?(BLACKLISTED_COLUMNS)
        return Failure(blacklisted_columns_error)
      end

      required_columns = campaign.project.data_schema.keys - BLACKLISTED_COLUMNS
      missing_columns = required_columns - dataframe.schema.keys
      unless missing_columns.empty?
        return Failure(missing_fields_error(missing_columns))
      end

      response = ::CaucisionMl.save_campaign_data(
        campaign_data_id: campaign.data_id,
        project_id: campaign.project.id,
        file: HTTP::FormData::File.new(params[:file].path)
      )

      # TODO: Add proper error handling here
      return Failure(Errors::InternalError.new) unless response.status.success?

      Rails.cache.write(campaign.data_id, response.body.to_s)

      campaign.update!(data_imported: true)

      Success(campaign)
    end

    private

      def build_data_schema(dataframe)
        dataframe.schema.to_h do |column, type|
          data_schema = {
            type: Scylla::QueryHandlers::Base::TYPE_MAPPINGS[type],
            unique_values: dataframe.n_unique(subset: [column])
          }

          [column, data_schema]
        end
      end

      def missing_fields_error(fields)
        Errors::InvalidParamsError.new(
          "#{fields.join(', ')} are missing"
        )
      end

      def blacklisted_columns_error
        Errors::InvalidParamsError.new(
          'CSV file must not contain either promotion or outcome column'
        )
      end
  end
end
