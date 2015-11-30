module AuthRocket
  class AuthProvider < Resource
    crud :all, :find, :create, :update, :delete

    belongs_to :realm

    attr :name, :provider_type, :state
    attr :email_verification, :login, :name_field, :password_field, :signup, :signup_mode, :verify
    attr :min_complexity, :min_length, :required_chars
    attr :client_id, :client_secret, :scopes


    # attribs - :redirect_uri - required
    #         - :nonce        - optional
    def self.authorize_urls(attribs={})
      params = parse_request_params(attribs)
      parsed, creds = request(:get, url+'/authorize', params)
      if parsed[:errors].any?
        raise Error, parsed[:errors].inspect
      end
      NCore::Collection.new.tap do |coll|
        coll.metadata = parsed[:metadata]
        parsed[:data].each do |hash|
          coll << GenericObject.new(hash.merge(metadata: parsed[:metadata]), creds)
        end
      end
    end

    # attribs - :redirect_uri - required
    #         - :nonce        - optional
    def self.authorize_url(auth_provider_id, attribs={})
      params = parse_request_params(attribs)
      parsed, creds = request(:get, url+"/#{auth_provider_id}/authorize", params)
      if parsed[:errors].any?
        raise Error, parsed[:errors].inspect
      end
      parsed[:data][:url]
    end

    # same as self.authorize_url(self.id, ...)
    def authorize_url(attribs={})
      params = parse_request_params(attribs).merge credentials: api_creds
      self.class.authorize_url(id, params)
    end

    # attribs - :code  - required
    #         - :nonce - optional
    #         - :state - required
    # always returns a new object; check .errors? or .valid? to see how it went
    def self.authorize(attribs={})
      params = parse_request_params(attribs)
      parsed, creds = request(:post, url+'/authorize', params)
      User.new(parsed, creds)
    end

    # attribs - :access_token - required
    # always returns a new object; check .errors? or .valid? to see how it went
    def authorize_token(attribs={})
      params = parse_request_params(attribs)
      parsed, creds = request(:post, url+'/authorize', params)
      User.new parsed, creds
    end

  end
end
