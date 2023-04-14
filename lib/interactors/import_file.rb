module Interactors
  class ImportFile < BaseInteractor

    REQUIRED_COLUMNS = %w(promotion outcome user_id).freeze

    def call(params, user)
      dataframe = Polars.read_csv(params[:file], ignore_errors: true)

      missing_columns = REQUIRED_COLUMNS - dataframe.schema.keys
      unless missing_columns.empty?
        return Failure(missing_fields_error(missing_columns))
      end

      project = Project.find_by(id: params[:id], user_id: user.id)
      return Failure(Error::NotFoundError.build(Project, params[:id])) unless project

      project.update!(data_imported: true)
      Success
    end

    private

      def missing_fields_error(fields)
        Errors::InvalidParamsError.new(
          "#{fields.join(', ')} are missing"
        )
      end
  end
end
