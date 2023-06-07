module Searchable
  class CampaignSerializer < ::CampaignSerializer
    attribute :type

    def type
      'Campaign'
    end
  end
end
