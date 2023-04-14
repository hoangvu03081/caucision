class ProjectsController < ApplicationController
  before_action :doorkeeper_authorize!

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
      render(json: project)
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

  params_for(:import_file) do
    required(:file).filled
  end

  def import_file
    result = Interactors::ImportFile.new.call(params, current_user)

    if result.success?
      render :ok
    else
      render_errors(result.failure)
    end

  end

  private

    def current_user
      if Rails.env.development?
        User.first
      elsif doorkeeper_token
        User.find(doorkeeper_token.resource_owner_id)
      end
    end
end
