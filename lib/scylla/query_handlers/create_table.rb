module Scylla
  module QueryHandlers
    class CreateTable < Base

      def call(table_name:, schema:, primary_key:)
        mapped_schema = scylla_schema_from(schema, primary_key)
        query = build_query(table_name, mapped_schema)

        session.execute(query)
        Success()
      rescue Cassandra::Errors::AlreadyExistsError
        Success()
      end

      private

        def scylla_schema_from(schema, primary_key)
          schema
            .transform_values { |type| TYPE_MAPPINGS[type] }
            .map { |column, type| "#{column} #{type}" }
            .tap { |list| list.push("PRIMARY KEY (#{primary_key})") }
            .join(', ')
        end

        def build_query(table_name, mapped_schema)
          <<-CQL
            CREATE TABLE #{table_name} (
              #{mapped_schema}
            )
          CQL
        end
    end
  end
end
