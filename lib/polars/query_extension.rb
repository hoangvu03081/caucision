module Polars
  module QueryExtension
    TYPE_CONVERSION_MAPPINGS = {
      Polars::Int8 => 'to_i',
      Polars::Int16 => 'to_i',
      Polars::Int32 => 'to_i',
      Polars::Int64 => 'to_i',
      Polars::UInt8 => 'to_i',
      Polars::UInt16 => 'to_i',
      Polars::UInt32 => 'to_i',
      Polars::UInt64 => 'to_i',
      Polars::Float32 => 'to_f',
      Polars::Float64 => 'to_f',
      Polars::Utf8 => 'to_s'
    }.freeze

    class << self
      def query(dataframe, filter_by: nil, sort_by: nil)
        dataframe = filter(dataframe, filter_by:) if filter_by
        dataframe = sort(dataframe, sort_by:) if sort_by

        dataframe
      end

      # aggregate: [{ "column": "recency", "operation": "sum" }]
      def aggregate(dataframe, group_by:, aggregate:)
        aggregation_operations = aggregate.map do |agg|
          col = Polars.col(agg[:column])

          if agg[:operation]
            col = col.send(agg[:operation]).suffix("_#{agg[:operation]}")
          end

          col
        end

        dataframe
          .groupby(Array.wrap(group_by), maintain_order: true)
          .agg(aggregation_operations)
      end

      def paginate(dataframe, offset:, limit:)
        dataframe.slice(offset, limit)
      end

      def filter(dataframe, filter_by:)
        filter_by = filter_by.select { |column| dataframe.columns.include?(column) }

        filter_by = filter_by.to_h do |column, value|
          column_dtype = dataframe[column].dtype
          conversion_method = TYPE_CONVERSION_MAPPINGS[column_dtype]

          [column, conversion_method ? value.send(conversion_method) : value]
        end

        conditions =
          filter_by
            .map { |column_name, value| (Polars.col(column_name) == value) }
            .reduce(:&)

        dataframe.filter(conditions)
      end

      def sort(dataframe, sort_by:)
        reverse_list = sort_by.values.map { |order| order.downcase == 'desc' }

        dataframe.sort(sort_by.keys, reverse: reverse_list)
      end
    end
  end
end
