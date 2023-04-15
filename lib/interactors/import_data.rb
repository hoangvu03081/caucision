module Interactors
  class ImportData < BaseInteractor
    include ::Dependency['create_table', 'batch_insert']

    REQUIRED_COLUMNS = %w(promotion outcome user_id).freeze

    def call(params, user)
      dataframe = Polars.read_csv(params[:file], ignore_errors: true)

      missing_columns = REQUIRED_COLUMNS - dataframe.schema.keys
      unless missing_columns.empty?
        return Failure(missing_fields_error(missing_columns))
      end

      project = Project.find_by(id: params[:id], user_id: user.id)
      return Failure(Errors::NotFoundError.build(Project, params[:id])) unless project

      table_name = project.data_id

      yield create_table.call(
        table_name:,
        schema: dataframe.schema,
        primary_key: :user_id
      )

      yield batch_insert.call(table_name:, dataframe:)

      project.update!(data_imported: true)
      Success()
    end

    private

      def missing_fields_error(fields)
        Errors::InvalidParamsError.new(
          "#{fields.join(', ')} are missing"
        )
      end
  end
end
