module Scylla
  KEYSPACE = 'caucision'.freeze
  HOSTS = [ENV.fetch('SCYLLA_HOST')].freeze

  def self.cluster
    @cluster ||= Cassandra.cluster(host: HOSTS).tap do |cluster|
      cluster.connect(KEYSPACE)
    end
  end

  module PreparedStatements
    CREATE_KEYSPACE = ''.freeze
  end
end
