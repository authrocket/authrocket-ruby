module AuthRocket
  class AuthProvider < Resource
    crud :all, :find, :create, :update, :delete

    belongs_to :realm

    attr :name, :provider_type, :state
    attr :min_complexity, :min_length
    attr :client_id, :client_secret, :scopes
    attr :loginrocket_domain
    attr :authorization_url, :profile_url, :token_url
    attr :email_field, :email_verified_field, :first_name_field, :id_field, :last_name_field, :name_field
    attr :auth_url # readonly


    # same as self.authorize_url(self.id, ...)
    def authorize_url(attribs={})
      self.class.authorize_url id, attribs.reverse_merge(credentials: api_creds)
    end

    # attribs - :access_token - required
    # returns: Session
    # always returns a new object; check .errors? or .valid? to see how it went
    def authorize_token(attribs={})
      params = parse_request_params(attribs)
      parsed, creds = request(:post, resource_path+'/authorize', params)
      self.class.factory(parsed, creds)
    end


    class << self

      # attribs - :redirect_uri - required
      #         - :nonce        - optional
      # returns: Array of simplified AuthProviders
      def authorize_urls(attribs={})
        params = parse_request_params(attribs)
        parsed, creds = request(:get, resource_path+'/authorize', params)
        raise QueryError, parsed[:errors] if parsed[:errors].any?
        NCore::Collection.new.tap do |coll|
          coll.metadata = parsed[:metadata]
          parsed[:data].each do |hash|
            coll << factory(hash.merge(metadata: parsed[:metadata]), creds)
          end
        end
      end

      # attribs - :redirect_uri - required
      #         - :nonce        - optional
      # returns: simplified AuthProvider
      def authorize_url(auth_provider_id, attribs={})
        params = parse_request_params(attribs)
        parsed, creds = request(:get, resource_path+"/#{CGI.escape auth_provider_id}/authorize", params)
        raise QueryError, parsed[:errors] if parsed[:errors].any?
        factory(parsed, creds)
      end

      # attribs - :code  - required
      #         - :nonce - optional
      #         - :state - required
      # returns: Session
      # always returns a new object; check .errors? or .valid? to see how it went
      def authorize(attribs={})
        params = parse_request_params(attribs)
        parsed, creds = request(:post, resource_path+'/authorize', params)
        factory(parsed, creds)
      end

    end

  end
end
