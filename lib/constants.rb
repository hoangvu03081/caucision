module Constants
  AGGREGATION_OPERATIONS = %w(
    count sum mean median
    min max std
  ).freeze

  module Queue
    DATA_IMPORTED = 'data_imported'.freeze
  end
end
