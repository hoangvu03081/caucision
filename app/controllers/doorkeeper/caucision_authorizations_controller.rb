# frozen_string_literal: true

module Doorkeeper
  class CaucisionAuthorizationsController < AuthorizationsController

    def new
      redirect_to authorize_response.redirect_uri, allow_other_host: true
    end
  end
end
