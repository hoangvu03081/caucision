module Polars
  module QueryExtension
    def self.query(dataframe, filter_by: nil, sort_by: nil)
      dataframe = filter(dataframe, filter_by:) if filter_by
      dataframe = sort(dataframe, sort_by:) if sort_by

      dataframe
    end

    def self.paginate(dataframe, offset:, limit:)
      dataframe.slice(offset, limit)
    end

    def self.filter(dataframe, filter_by:)
      conditions =
        filter_by
          .map { |column_name, value| (Polars.col(column_name) == value) }
          .reduce(:&)

      dataframe.filter(conditions)
    end

    def self.sort(dataframe, sort_by:)
      reverse_list = sort_by.values.map { |order| order.downcase == 'desc' }

      dataframe.sort(sort_by.keys, reverse: reverse_list)
    end
  end
end
