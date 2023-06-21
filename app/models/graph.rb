class Graph < ApplicationRecord
  belongs_to :project, optional: true
  belongs_to :campaign, optional: true

  def owner
    if project_id
      project
    elsif campaign_id
      campaign
    end
  end
end
