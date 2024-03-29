class Notification < ApplicationRecord
  def self.model_training_completed(
    project_name:, project_id:, user_id:, campaign_id:, training_results:
  )
    create(
      message_type: 'model_training_completed',
      message: "Your project #{project_name} has finished the training process",
      metadata: { project_id:, campaign_id:, training_results: },
      user_id:
    )
  end
end
