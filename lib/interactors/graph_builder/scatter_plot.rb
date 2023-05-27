module Interactors
  module GraphBuilder
    class ScatterPlot < Base

      private

        def build_graph(query_details, dataframe)
          x_axis = query_details[:x_axis]
          y_axis = query_details[:y_axis]
          group_by = query_details[:group_by]

          series =
            if group_by
              aggregate = [{ column: x_axis }, { column: y_axis }]

              aggregated_dataframe = Polars::QueryExtension.aggregate(
                dataframe, group_by:, aggregate:
              )

              aggregated_dataframe.rows(named: true).map do |row|
                name = row[group_by]
                data = [row[x_axis], row[y_axis]].transpose

                { name:, data: }
              end
            else
              name = "#{x_axis} - #{y_axis}"
              data = dataframe[[x_axis, y_axis]].rows

              [{ name:, data: }]
            end

          { series: }
        end

        def schema
          Dry::Schema.Params do
            optional(:group_by).filled(:string)
            required(:x_axis).filled(:string)
            required(:y_axis).filled(:string)
          end
        end
    end
  end
end
