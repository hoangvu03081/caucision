class ProjectShowSerializer < ProjectSerializer
  has_many :campaigns, serializer: CampaignSerializer
end
