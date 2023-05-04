class Graph < ApplicationRecord
  belongs_to :project, optional: true
  belongs_to :campaign, optional: true
end
