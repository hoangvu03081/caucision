module Users
  class SessionsController < ::Devise::SessionsController
    include ActionController::Cookies

    def destroy
      Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
      render status: 200
    end

    private

      def respond_to_on_destroy; end
  end
end
