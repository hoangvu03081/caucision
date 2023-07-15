# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

model = Doorkeeper.config.application_model

record = model.find_by(name: 'Frontend App')

record_params = {
  name:   'Frontend App',
  uid:    Rails.application.credentials[:frontend_client_id],
  secret: Rails.application.credentials[:frontend_client_secret],
  redirect_uri: ENV['CALLBACK_URL'],
  confidential: false
}

if record
  record.update(**record_params)
else
  model.create(**record_params)
end
