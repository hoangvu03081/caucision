class ApplicationController < ActionController::API
  include ::ParameterValidation

  def render_errors(*errors, status: 400)
    render(json: { errors: errors.flatten.map(&:to_h) }, status:)
  end
end
