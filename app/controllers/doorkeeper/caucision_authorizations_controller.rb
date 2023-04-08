# frozen_string_literal: true

module Doorkeeper
  class CaucisionAuthorizationsController < AuthorizationsController
    prepend_before_action :set_session_data, only: [:new]

    include ::ParameterValidation

    # TODO: Add format validation
    params_for(:new) do
      required(:client_id).filled(:str?)
      required(:redirect_uri).filled(:str?)
      required(:response_type).filled(:str?)
      optional(:code_challenge).filled(:str?)
      optional(:code_challenge_method).filled(:str?, included_in?: %w(plain S256))
      optional(:scope).filled(:str?)
      optional(:state).filled(:str?)

      # used for redirection at callback controller
      required(:controller).filled(:str?)
      required(:action).filled(:str?)
    end

    def new
      redirect_to authorize_response.redirect_uri, allow_other_host: true
    end

    private

      # Used in Users::OmniauthCallbacksController
      def set_session_data
        session[:redirection_params] = params.to_h
      end
  end
end
