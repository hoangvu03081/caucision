class CampaignsController < ApplicationController
  before_action :authorize!

  params_for(:index) do
    required(:project_id).value(:str?)
  end

  def index
    campaigns = Campaign.where(
      user_id: current_user.id, project_id: params[:project_id]
    )

    render(json: campaigns)
  end

  params_for(:create) do
    required(:name).filled(:str?)
    required(:project_id).value(:str?)
  end

  def create
    campaign = Campaign.create!(params.merge(user_id: current_user.id))
    render(json: campaign, status: 201)
  end

  def show
    campaign = Campaign.find_by(id: params[:id], user_id: current_user.id)

    if campaign
      render(json: campaign)
    else
      render_errors(Errors::NotFoundError.build(Campaign, params[:id]))
    end
  end

  params_for(:update) do
    required(:id).filled(:str?) # TODO: Update to uuid v4
    optional(:name).filled(:str?)
  end

  def update
    campaign = Campaign.find_by(id: params[:id], user_id: current_user.id)

    if campaign
      campaign.update(params)
      render(json: campaign.reload)
    else
      render_errors(Errors::NotFoundError.build(Campaign, params[:id]))
    end
  end

  def destroy
    campaign = Campaign.find_by(id: params[:id], user_id: current_user.id)

    if campaign
      campaign.destroy # TODO: Update logic for delete cascade
      render(status: 200)
    else
      render_errors(Errors::NotFoundError.build(Campaign, params[:id]))
    end
  end

  params_for(:import_data) do
    required(:file).filled
    required(:id).filled(:str?)
  end

  def import_data
    result = Interactors::ImportCampaignData.new.call(params, current_user)

    if result.success?
      render(json: result.value!)
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
      params.to_h, current_user, from: :campaign
    )

    if result.success?
      pagy, data, headers = pagy_dataframe(result.value!)
      render json: { columns: headers, data:, metadata: pagy_metadata(pagy) }
    else
      render_errors(result.failure)
    end
  end

  def query_graph
    render(status: 200)
  end
end
