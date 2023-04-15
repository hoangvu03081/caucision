# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

Doorkeeper.config.application_model.create(
  name:   'Frontend App',
  uid:    Rails.application.credentials[:frontend_client_id],
  secret: Rails.application.credentials[:frontend_client_secret],
  redirect_uri: 'http://localhost:3000/auth-callback',
  confidential: false
)
