class NotificationChannel < ApplicationCable::Channel
  def subscribed
    stream_from "notification:#{current_user.id}"
  end
end
