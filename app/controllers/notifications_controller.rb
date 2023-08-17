class NotificationsController < ApplicationController
  before_action :authorize!

  def index
    notifications = Notification
                      .where(user_id: current_user.id)
                      .order(created_at: :desc)

    notifications.training_results = notifications.training_results.sort do |a, b|
      a[1][:rmse] <=> b[1][:rmse]
    end

    render(json: notifications)
  end

  params_for(:update) do
    required(:id).filled(:str?) # TODO: Update to uuid v4
    required(:viewed).filled(:bool)
  end

  def update
    notification = Notification.find_by(id: params[:id], user_id: current_user.id)

    if notification
      notification.update(params)
      render(json: notification.reload)
    else
      render_errors(Errors::NotFoundError.build(Notification, params[:id]))
    end
  end
end
