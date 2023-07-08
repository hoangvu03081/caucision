module Interactors
  class QueryGraph < BaseInteractor
    include Dependency['fetch_table']

    # Bar, Column, Radar has the same format
    GRAPH_BUILDER_MAPPINGS = {
      'column' => Interactors::GraphBuilder::Column,
      'bar' => Interactors::GraphBuilder::Column,
      'radar' => Interactors::GraphBuilder::Column,
      'pie' => Interactors::GraphBuilder::Pie,
      'scatter' => Interactors::GraphBuilder::ScatterPlot
    }.freeze

    def call(params, user, type)
      result = yield fetch_table.call(params, user, from: type)
      dataframe, _ = result

      graph_builder = GRAPH_BUILDER_MAPPINGS.fetch(params[:type])
      graph_builder.new.call(params, dataframe)
    end
  end
end
