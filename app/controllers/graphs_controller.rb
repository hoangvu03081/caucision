class GraphsController < ApplicationController
  before_action :authorize!

  params_for(:index) do
    optional(:project_id).filled(:str?) # TODO: Update to uuid v4
    optional(:campaign_id).filled(:str?) # TODO: Update to uuid v4
  end

  def index
    result = Interactors::FetchGraphs.new.call(params.to_h, current_user)

    if result.success?
      render(json: result.value!)
    else
      render_errors(Errors::NotFoundError.build(Project, params[:id]))
    end
  end

  params_for(:create) do
    optional(:project_id).filled(:str?) # TODO: Update to uuid v4
    optional(:campaign_id).filled(:str?) # TODO: Update to uuid v4
    required(:data).filled(:hash?)
  end

  def create
    result = Interactors::CreateGraph.new.call(params.to_h, current_user)

    if result.success?
      render(json: result.value!)
    else
      render_errors(result.failure)
    end
  end

  params_for(:update) do
    required(:id).filled(:str?) # TODO: Update to uuid v4
    required(:data).filled(:hash?)
  end

  def update
    graph = Graph.find_by(id: params[:id])

    if graph
      graph.update(params)
      render(json: graph.reload)
    else
      render_errors(Errors::NotFoundError.build(Graph, params[:id]))
    end
  end

  params_for(:destroy) do
    required(:id).filled(:str?) # TODO: Update to uuid v4
  end

  def destroy
    result = Interactors::DestroyGraph.new.call(params.to_h, current_user)

    if result.success?
      render(status: 200)
    else
      render_errors(result.failure)
    end
  end
end
