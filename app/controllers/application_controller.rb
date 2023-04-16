class ApplicationController < ActionController::API
  include ::ParameterValidation
  include Pagy::Backend

  def render_errors(*errors, status: 400)
    render(json: { errors: errors.flatten.map(&:to_h) }, status:) # TOOD: Check if use serializer possible
  end

  def current_user
    if Rails.env.development?
      User.first
    elsif doorkeeper_token
      User.find(doorkeeper_token.resource_owner_id)
    end
  end

  def pagy_dataframe(dataframe, vars = {})
    pagy = Pagy.new(count: dataframe.length, page: params[:page], **vars)

    headers = dataframe.columns

    paginated_dataframe = Polars::QueryExtension.paginate(
      dataframe,
      offset: pagy.offset,
      limit: pagy.items
    ).rows

    [pagy, paginated_dataframe, headers]
  end
end
