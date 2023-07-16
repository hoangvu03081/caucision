class CampaignSerializer < ActiveModel::Serializer
  attributes :id, :name, :data_imported, :project_id, :data_schema

  attribute :optimized do
    object.optimized?
  end
end
