class ProjectShowSerializer < ProjectSerializer
  has_many :campaigns, serializer: CampaignSerializer

  attributes :data_schema
end
