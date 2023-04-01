class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :confirmable, :omniauthable,
         omniauth_providers: %i[google_oauth2]

  UPSERT_USER_PROVIDERS = %w[google_oauth2].freeze

  def self.from_omniauth(access_token)
    provider = access_token['provider']
    email = access_token.info['email']

    user = User.find_by(email:)

    if user.nil? && UPSERT_USER_PROVIDERS.include?(provider)
      user = User.create!(
        email:,
        provider:,
        confirmed_at: Time.now
      )
    end

    user && user.provider != provider ? nil : user
  end
end
