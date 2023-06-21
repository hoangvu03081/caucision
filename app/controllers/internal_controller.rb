class InternalController < ApplicationController
  params_for(:create_default_campaign) do
    required(:project_id).filled(:str?)
    required(:user_id).filled(:str?)
    required(:data_schema).filled(:hash?)
  end

  def create_default_campaign
    Campaign.create!(
      id: params[:project_id],
      user_id: params[:user_id],
      project_id: params[:project_id],
      data_imported: true,
      name: 'Default campaign',
      data_schema: params[:data_schema]
    )

    render(status: 201)
  end
end
