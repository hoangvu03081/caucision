class InternalController < ApplicationController
  params_for(:create_default_campaign) do
    required(:project_id).filled(:str?)
    required(:user_id).filled(:str?)
    required(:data_schema).filled(:hash?)
    required(:training_results).filled(:hash?)
  end

  def create_default_campaign
    training_results = params[:training_results].to_h.deep_symbolize_keys

    training_results = training_results.sort do |a, b|
      a[1][:rmse] <=> b[1][:rmse]
    end.to_h do |key, value|
      value = value.merge(
        rmse: value[:rmse].round(5),
        training_time: value[:training_time].round(3)
      )

      [key, value]
    end

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
      campaign_id: campaign.id,
      training_results:
    )

    NotificationChannel.broadcast_to(
      params[:user_id],
      notification
    )

    render(status: 201)
  end
end
