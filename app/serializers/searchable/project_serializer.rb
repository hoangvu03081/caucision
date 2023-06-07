module Searchable
  class ProjectSerializer < ::ProjectSerializer
    attribute :type

    def type
      'Project'
    end
  end
end
