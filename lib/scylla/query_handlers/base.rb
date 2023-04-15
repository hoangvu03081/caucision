module Scylla
  module QueryHandlers
    class Base < BaseInteractor

      TYPE_MAPPINGS = {
        Polars::Int64 => 'integer',
        Polars::Float64 => 'float',
        Polars::Utf8 => 'text'
      }.freeze

      private

        def session
          Scylla.session
        end
    end
  end
end
