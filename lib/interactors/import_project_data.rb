module Interactors
  class ImportProjectData < BaseInteractor
    include ::Dependency['create_table', 'batch_insert']

    REQUIRED_COLUMNS = %w(promotion outcome user_id).freeze

    def call(params, user)
      Rails.logger.info("vu.hoang (1)")
      dataframe = Polars.read_csv(params[:file], ignore_errors: true)

      missing_columns = REQUIRED_COLUMNS - dataframe.schema.keys
      unless missing_columns.empty?
        return Failure(missing_fields_error(missing_columns))
      end

      # TODO: Check if control_promotion is in promotion column values list

      project = Project.find_by(id: params[:id], user_id: user.id)
      return Failure(Errors::NotFoundError.build(Project, params[:id])) unless project
      Rails.logger.info("vu.hoang (2)")

      table_name = project.data_id
      Rails.logger.info("vu.hoang (3)")

      yield create_table.call(
        table_name:,
        schema: dataframe.schema,
        primary_key: :user_id
      )
      Rails.logger.info("vu.hoang (4)")

      yield batch_insert.call(table_name:, dataframe:)
      Rails.logger.info("vu.hoang (5)")

      data_schema = build_data_schema(dataframe)

      project.update!(
        data_imported: true,
        control_promotion: params[:control_promotion],
        data_schema:,
        promotions: dataframe['promotion'].unique.to_a
      )

      Success(project)
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
  end
end
