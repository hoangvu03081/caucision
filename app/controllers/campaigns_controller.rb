class CampaignsController < ApplicationController
  before_action :authorize!

  params_for(:index) do
    required(:project_id).value(:str?)
  end

  def index
    campaigns = Campaign.where(
      user_id: current_user.id, project_id: params[:project_id]
    ).order(:created_at)

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
    campaign = fetch_campaign!
    render(json: campaign)
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
      dataframe, predicted_metadata = result.value!

      pagy, data, headers = pagy_dataframe(dataframe)

      render json: {
               columns: headers,
               data:,
               metadata: pagy_metadata(pagy),
               **predicted_metadata
             }
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
    result = Interactors::QueryGraph.new.call(params.to_h, current_user, :campaign)

    if result.success?
      render(json: result.value!)
    else
      render_errors(result.failure)
    end
  end

  def delete_optimization
    campaign = fetch_campaign!
    campaign.update!(
      optimization_result: nil,
      optimization_summary: nil,
      optimization_metadata: nil
    )

    render(status: 200)
  end

  params_for(:fetch_optimization_table) do
    required(:id).filled(:str?)
    optional(:filter).filled(:hash?)
    optional(:sort).filled(:hash?)

    optional(:page).filled(:integer, gt?: 0)
    optional(:limit).filled(:integer, gt?: 0)
  end

  def fetch_optimization_table
    result = Interactors::FetchOptimizationTable.new.call(params, current_user)

    if result.success?
      dataframe, predicted_metadata = result.value!

      pagy, data, headers = pagy_dataframe(dataframe)

      render json: {
               columns: headers,
               data:,
               metadata: pagy_metadata(pagy),
               **predicted_metadata
             }
    else
      render_errors(result.failure)
    end
  end

  def download_optimization_result
    result = Interactors::FetchOptimizationTable.new.call(params, current_user)

    if result.success?
      file = Tempfile.new(['optimization-result-', '.csv'])
      dataframe, _predicted_metadata = result.value!
      dataframe.write_csv(file)

      send_file file,
                type: 'text/csv; charset=utf-8; header=present',
                disposition: 'attachment; filename=optimization_result.csv'
    else
      render_errors(result.failure)
    end
  end

  def fetch_optimization_summary
    result = Interactors::FetchOptimizationSummary.new.call(params, current_user)

    if result.success?
      render(json: result.value!)
    else
      render_errors(result.failure)
    end
  end

  params_for(:create_optimization) do
    required(:id).filled(:str?)
    required(:budget).filled(:float)
    optional(:file).filled
    optional(:promotion_costs).filled(:hash?)
  end

  def create_optimization
    result = Interactors::CreateOptimization.new.call(params, current_user)

    if result.success?
      render(status: 201)
    else
      render_errors(result.failure)
    end
  end

  def sample_campaign_data
    render(status: 201)
  end

  def sample_promotion_costs
    render(status: 201)
  end

  private

    def fetch_campaign!
      campaign = Campaign.find_by(id: params[:id], user_id: current_user.id)

      render_errors(Errors::NotFoundError.build(Campaign, params[:id])) unless campaign

      campaign
    end
end
