module AuthRocket
  module Client
    extend ActiveSupport::Concern

    module ClassMethods

      def parse_credentials(creds)
        creds.with_indifferent_access.except :loginrocket_url, :jwt_key
      end

    end

  end
end
