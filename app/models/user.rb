class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :confirmable, :omniauthable,
         omniauth_providers: %i[google_oauth2]

  USER_INFO_FIELDS = %w[name first_name last_name image].freeze

  def self.from_omniauth(access_token)
    provider = access_token['provider']
    email = access_token.info['email']
    user_info = access_token.info.slice(*USER_INFO_FIELDS)

    upsert_params = { provider:, email:, **user_info }

    user = User.find_by(email:)

    if user
      user.update!(**upsert_params)
      user
    else
      User.create!(**upsert_params)
    end
  end
end
