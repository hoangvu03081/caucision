module Polars
  module QueryExtension
    class << self
      def query(dataframe, filter_by: nil, sort_by: nil)
        dataframe = filter(dataframe, filter_by:) if filter_by
        dataframe = sort(dataframe, sort_by:) if sort_by

        dataframe
      end

      # aggregate: [{ "column": "recency", "operation": "sum" }]
      def aggregate(dataframe, group_by:, aggregate:)
        aggregation_operations = aggregate.map do |agg|
          Polars
            .col(agg[:column])
            .send(agg[:operation])
            .suffix("_#{agg[:operation]}")
        end

        dataframe
          .groupby(Array.wrap(group_by))
          .agg(aggregation_operations)
      end

      def paginate(dataframe, offset:, limit:)
        dataframe.slice(offset, limit)
      end

      def filter(dataframe, filter_by:)
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
