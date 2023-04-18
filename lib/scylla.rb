require 'cassandra'

module Scylla
  KEYSPACE = 'caucision'.freeze
  HOSTS = [ENV.fetch('SCYLLA_HOST')].freeze

  KEYSPACE_DEFINITION = <<-KEYSPACE_CQL.freeze
    CREATE KEYSPACE #{KEYSPACE}
    WITH replication = {'class': 'SimpleStrategy', 'replication_factor' : 1};
  KEYSPACE_CQL

  # TODO: Better handling for checking existing keyspace
  def self.cluster
    @cluster ||= Cassandra.cluster(hosts: HOSTS).tap do |cluster|
      session = cluster.connect('system')
      session.execute(KEYSPACE_DEFINITION)
    rescue Cassandra::Errors::AlreadyExistsError # rubocop:disable Lint/SuppressedException
    end
  end

  def self.session
    @session ||= cluster.connect(KEYSPACE)
  end

  module QueryHandlers
    class Base < BaseInteractor

      TYPE_MAPPINGS = {
        Polars::Int64 => 'int',
        Polars::Float64 => 'float',
        Polars::Utf8 => 'text'
      }.freeze

      private

        def session
          Scylla.session
        end
    end

    class CreateTable < Base
      def call(table_name:, schema:, primary_key:)
        mapped_schema = scylla_schema_from(schema, primary_key)
        query = build_query(table_name, mapped_schema)

        session.execute(query)
        Success()
      rescue Cassandra::Errors::AlreadyExistsError
        Failure(Errors::AlreadyImportedError.new)
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

    class BatchInsert < Base

      BATCH_SIZE = 100

      def call(table_name:, dataframe:)
        prepared_statement = prepare_statement(table_name, dataframe)

        batch_count = dataframe.length / BATCH_SIZE

        batch_count.times do |page|
          batch = session.batch do |b|
            offset = page * BATCH_SIZE

            dataframe.slice(offset, BATCH_SIZE).iter_rows(named: false) do |row|
              b.add(prepared_statement, arguments: row)
            end
          end

          session.execute(batch, consistency: :any)
        end

        Success()
      end

      private

        def prepare_statement(table_name, dataframe)
          values = (1..dataframe.schema.length)
                     .map { '?' }
                     .join(', ')

          session.prepare(
            <<-CQL
              INSERT INTO #{table_name} (
                #{dataframe.schema.keys.join(', ')}
              ) VALUES (#{values})
            CQL
          )
        end
    end

    class Select < Base

      DEFAULT_LIMIT = 1000000

      def call(table_name:)
        cached_data = Rails.cache.read(table_name)

        if cached_data
          buffer = StringIO.new(cached_data)
          return Success(Polars.read_csv(buffer))
        end

        query = build_query(table_name)

        result = session.execute(query)
        dataframe = Polars::DataFrame.new(result.to_a)

        loop do
          break if result.last_page?

          result = result.next_page
          dataframe = dataframe.vstack(Polars::DataFrame.new(result.to_a))
        end

        Rails.cache.write(table_name, dataframe.to_csv)
        Success(dataframe)
      end

      private

        def build_query(table_name)
          "SELECT * FROM #{table_name}"
        end
    end
  end
end
