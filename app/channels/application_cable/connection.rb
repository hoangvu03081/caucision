module ApplicationCable
  class Connection < ActionCable::Connection::Base
    include Doorkeeper::Rails::Helpers

    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

      def find_verified_user
        user = if Rails.env.development?
                 User.first
               elsif doorkeeper_token
                 User.find(doorkeeper_token.resource_owner_id)
               end

        Rails.logger.info("User: #{user}")

        reject_unauthorized_connection unless user

        user
      end
  end
end
