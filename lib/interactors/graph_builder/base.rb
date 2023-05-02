module Interactors
  module GraphBuilder
    class Base < BaseInteractor

      def call(params, dataframe)
        validated_query_details = yield validate(params)
        graph = build_graph(validated_query_details, dataframe)
        Success(graph.deep_merge(default_options(params)))
      end

      private

        def validate(params)
          validation_result = schema.call(params[:query_details])

          if validation_result.failure?
            errors = validation_result.errors.to_h
            formatted_errors = Validations::Message.new
              .build(errors)
              .map { |message| Errors::InvalidParamsError.new(message) }

            return Failure(formatted_errors)
          end

          Success(validation_result.to_h)
        end

        def schema
          raise NotImplementedError
        end

        def build_graph(query_details, dataframe)
          raise NotImplementedError
        end

        def default_options(params)
          {
            options: { title: params[:title] }
          }
        end
    end
  end
end
