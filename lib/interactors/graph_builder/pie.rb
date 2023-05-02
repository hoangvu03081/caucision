module Interactors
  module GraphBuilder
    class Pie < Base

      private

        def build_graph(query_details, dataframe)
          group_by = query_details[:group_by]
          aggregate = Array.wrap(query_details[:aggregate].first)

          aggregated_dataframe = Polars::QueryExtension.aggregate(
            dataframe, group_by:, aggregate:
          )

          # column_labels will only have 1 member
          column_labels = aggregated_dataframe.columns - group_by
          group_labels = aggregated_dataframe[group_by].rows.map { |values| values.join(', ') }

          series = to_series_data(aggregated_dataframe, column_labels.first)

          to_apex_chart(series, group_labels)
        end

        def to_series_data(dataframe, column_label)
          dataframe[column_label].to_a
        end

        def to_apex_chart(series, group_labels)
          {
            series:,
            options: {
              labels: group_labels
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
