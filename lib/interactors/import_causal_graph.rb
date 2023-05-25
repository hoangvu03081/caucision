module Interactors
  class ImportCausalGraph < BaseInteractor
    include Dependency['message_queue']

    def call(params, user)
      project = Project.find_by(id: params[:id], user_id: user.id)

      return Failure(Errors::NotFoundError.build(Project, params[:id])) unless project
      return Failure(data_not_imported_error) unless project.data_imported?

      schema = project.data_schema
      causal_graph = params[:causal_graph].stringify_keys
      causal_graph = causal_graph.merge({
        'outcome' => ['conversion'],
        'conversion' => []
      })

      required_columns = schema.except('user_id').keys
      missing_columns = required_columns - causal_graph.keys

      unless missing_columns.empty?
        return Failure(missing_fields_error(missing_columns))
      end

      return Failure(invalid_dag_error) unless valid_dag?(causal_graph)

      serialized_graph = serialize_graph(causal_graph)

      project.update!(causal_graph: serialized_graph)

      message_queue.direct_publish(
        Constants::Queue::DATA_IMPORTED, { project_id: project.id }
      )

      Success()
    end

    private

      def valid_dag?(causal_graph)
        each_node = ->(&b) { causal_graph.each_key(&b) }
        each_child = ->(n, &b) { causal_graph[n].each(&b) }

        TSort.tsort(each_node, each_child)
        true
      rescue TSort::Cyclic
        false
      end

      def serialize_graph(causal_graph)
        links = causal_graph.flat_map do |key, values|
          values.map { |value| "#{key} -> #{value}" }
        end + causal_graph.keys.select do |key|
          causal_graph[key].empty?
        end

        "digraph {#{links.join('; ')}}"
      end

      def data_not_imported_error
        Errors::InvalidParamsError.new('Project data has not been imported before')
      end

      def missing_fields_error(fields)
        Errors::InvalidParamsError.new(
          "#{fields.join(', ')} are missing"
        )
      end

      def invalid_dag_error
        Errors::InvalidParamsError.new(
          'Provided graph is not a valid DAG'
        )
      end
  end
end
