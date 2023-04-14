FactoryBot.define do
  factory :user do
    id          { SecureRandom.uuid }
    email       { Faker::Internet.email }
    provider    { 'google_oauth2' }
  end
end
