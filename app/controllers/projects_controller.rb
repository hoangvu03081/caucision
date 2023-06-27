class ProjectsController < ApplicationController
  before_action :authorize!

  def index
    projects = Project.where(user_id: current_user.id)
    render(json: projects)
  end

  params_for(:create) do
    required(:name).filled(:str?)
    optional(:description).value(:str?)
  end

  def create
    project = Project.create!(params.merge(user_id: current_user.id))
    render(json: project, status: 201)
  end

  def show
    project = Project.find_by(id: params[:id], user_id: current_user.id)

    if project
      render(json: project, serializer: ProjectShowSerializer)
    else
      render_errors(Errors::NotFoundError.build(Project, params[:id]))
    end
  end

  params_for(:update) do
    required(:id).filled(:str?) # TODO: Update to uuid v4
    optional(:name).filled(:str?)
    optional(:description).value(:str?)
  end

  def update
    project = Project.find_by(id: params[:id], user_id: current_user.id)

    if project
      project.update(params)
      render(json: project.reload)
    else
      render_errors(Errors::NotFoundError.build(Project, params[:id]))
    end
  end

  def destroy
    project = Project.find_by(id: params[:id], user_id: current_user.id)

    if project
      project.destroy # TODO: Update logic for delete cascade
      render(status: 200)
    else
      render_errors(Errors::NotFoundError.build(Project, params[:id]))
    end
  end

  params_for(:import_data) do
    required(:file).filled
    required(:id).filled(:str?)
    required(:control_promotion).filled(:str?)
  end

  def import_data
    result = Interactors::ImportProjectData.new.call(params, current_user)

    if result.success?
      render(json: result.value!, serializer: ProjectShowSerializer)
    else
      render_errors(result.failure)
    end
  end

  params_for(:table) do
    required(:id).filled(:str?)
    optional(:filter).filled(:hash?)
    optional(:sort).filled(:hash?)

    optional(:page).filled(:integer, gt?: 0)
    optional(:limit).filled(:integer, gt?: 0)
  end

  def table
    result = Interactors::FetchTable.new.call(
      params.to_h, current_user, from: :project
    )

    if result.success?
      pagy, data, headers = pagy_dataframe(result.value!)
      render json: { columns: headers, data:, metadata: pagy_metadata(pagy) }
    else
      render_errors(result.failure)
    end
  end

  params_for(:import_causal_graph) do
    required(:id).filled(:str?)
    required(:causal_graph).filled(:hash?)
  end

  def import_causal_graph
    result = Interactors::ImportCausalGraph.new.call(params.to_h, current_user)

    if result.success?
      render :ok
    else
      render_errors(result.failure)
    end
  end

  params_for(:query_graph) do
    required(:id).filled(:str?)
    required(:type).filled(:str?, included_in?: Interactors::QueryGraph::GRAPH_BUILDER_MAPPINGS.keys)
    required(:query_details).filled(:hash?)
  end

  def query_graph
    result = Interactors::QueryGraph.new.call(params.to_h, current_user, :project)

    if result.success?
      render(json: result.value!)
    else
      render_errors(result.failure)
    end
  end

  def sample_dataset
    send_file Rails.root.join('spec', 'fixtures', 'files', 'sample_dataset.csv'),
              type: 'text/csv; charset=utf-8; header=present',
              disposition: 'attachment; filename=sample_dataset.csv'
  end
end
