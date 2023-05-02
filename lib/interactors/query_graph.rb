module Interactors
  class QueryGraph < BaseInteractor
    include Dependency['fetch_table']

    GRAPH_BUILDER_MAPPINGS = {
      'column' => Interactors::GraphBuilder::Column,
      'pie' => Interactors::GraphBuilder::Pie
    }.freeze

    def call(params)
      dataframe = yield fetch_table.call(params)

      graph_builder = GRAPH_BUILDER_MAPPINGS.fetch(params[:type])
      graph_builder.new.call(params, dataframe)
    end
  end
end
