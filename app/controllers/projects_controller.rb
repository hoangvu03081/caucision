class ProjectsController < ApplicationController
  before_action :doorkeeper_authorize!

  def index
    projects = Project.where(user_id: current_user.id)
    render(json: projects)
  end

  params_for(:create) do
    required(:name).filled(:str?)
    optional(:description).filled(:str?)
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

  def current_user
    if Rails.env.development?
      User.first
    elsif doorkeeper_token
      User.find(doorkeeper_token.resource_owner_id)
    end
  end
end
