class CampaignSerializer < ActiveModel::Serializer
  attributes :id, :name, :data_imported, :project_id

  attribute :optimized do
    object.optimized?
  end
end
