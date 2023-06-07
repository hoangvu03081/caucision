class SearchController < ApplicationController
  before_action :authorize!

  params_for(:index) do
    required(:q).filled(:str?)
    optional(:type).filled(:str?, included_in?: ['Project', 'Campaign'])

    optional(:page).filled(:integer, gt?: 0)
    optional(:limit).filled(:integer, gt?: 0)
  end

  def index
    metadata, data =
      pagy(
        PgSearch
          .multisearch(params[:q])
          .where({ user_id: current_user.id, searchable_type: params[:type] }.compact)
          .includes(:searchable),
        page: params[:page],
        items: params[:limit]
      )

    data = ActiveModelSerializers::SerializableResource.new(
      data.map(&:searchable),
      namespace: 'Searchable'
    ).as_json

    render(json: { data:, metadata: pagy_metadata(metadata) })
  end
end
