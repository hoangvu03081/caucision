module Constants
  AGGREGATION_OPERATIONS = %w(
    count sum mean median
    min max std
  ).freeze

  module Queue
    DATA_IMPORTED = 'data_imported'.freeze
  end

  MODEL_TYPES = [
    'Linear Regression',
    'XGBoost',
    'Tweedie',
    'Random Forest',
    'Support Vector Regression',
    'Decision Tree',
    'Perceptron',
    'K-nearest Neighbors',
    'Auto'
  ].freeze
end
