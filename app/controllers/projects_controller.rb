class ProjectsController < ApplicationController
  before_action :doorkeeper_authorize!

  def index
    render(json: current_resource_owner)
  end

  def create(params)
    # Projects.create!(params.to_h)
    render(json: current_resource_owner)
  end

  def current_resource_owner
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end
end
