class InternalController < ApplicationController
  params_for(:create_default_campaign) do
    required(:project_id).filled(:str?)
    required(:user_id).filled(:str?)
    required(:data_schema).filled(:hash?)
  end

  def create_default_campaign
    campaign = Campaign.create!(
      id: params[:project_id],
      user_id: params[:user_id],
      project_id: params[:project_id],
      data_imported: true,
      name: 'Default campaign',
      data_schema: params[:data_schema]
    )

    notification = Notification.model_training_completed(
      project_name: campaign.project.name,
      project_id: params[:project_id],
      user_id: params[:user_id],
      campaign_id: campaign.id
    )

    NotificationChannel.broadcast_to(
      params[:user_id],
      notification
    )

    render(status: 201)
  end
end
