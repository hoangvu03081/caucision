class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # skip_before_action :verify_authenticity_token, only: :google_oauth2

  def google_oauth2
    user = User.from_omniauth(request.env['omniauth.auth'])

    if user
      sign_in(user)
      redirect_to(**session[:redirection_params].symbolize_keys)
    else
      session['devise.google_data'] = request.env['omniauth.auth'].except('extra')
      redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
    end
  end
end
