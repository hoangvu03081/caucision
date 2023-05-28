class CampaignSerializer < ActiveModel::Serializer
  attributes :id, :name, :data_imported, :project_id
end
