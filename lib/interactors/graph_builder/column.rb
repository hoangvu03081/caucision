module Interactors
  module GraphBuilder
    class Column < Base

      private

        def build_graph(query_details, dataframe)
          group_by = query_details[:group_by]
          aggregate = query_details[:aggregate]

          aggregated_dataframe = Polars::QueryExtension.aggregate(
            dataframe, group_by:, aggregate:
          )

          column_labels = aggregated_dataframe.columns - group_by
          group_labels = aggregated_dataframe[group_by].rows.map { |values| values.join(', ') }

          series = to_series_data(aggregated_dataframe, column_labels)

          to_apex_chart(series, group_labels)
        end

        def to_series_data(dataframe, column_labels)
          column_labels.map do |label|
            {
              name: label.titleize,
              data: dataframe[label].to_a
            }
          end
        end

        def to_apex_chart(series, group_labels)
          {
            series:,
            options: {
              xaxis: {
                categories: group_labels
              }
            }
          }
        end

        def schema
          Dry::Schema.Params do
            required(:group_by).array(:string)
            required(:aggregate).array(:hash) do
              required(:column).filled(:str?)
              required(:operation).filled(:str?, included_in?: Constants::AGGREGATION_OPERATIONS)
            end
          end
        end
    end
  end
end
