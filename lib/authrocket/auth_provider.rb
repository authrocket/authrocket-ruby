module AuthRocket
  class AuthProvider < Resource
    crud :all, :find, :create, :update, :delete

    belongs_to :realm

    attr :provider_type, :state
    attr :login, :name_field, :signup
    attr :min_length
    attr :client_id, :client_secret, :scopes


    # attribs - :redirect_uri - required
    #         - :nonce        - optional
    def self.authorize_urls(attribs={}, api_creds=nil)
      parsed, creds = request(:get, url+'/authorize', api_creds, attribs)
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
    def self.authorize_url(auth_provider_id, attribs={}, api_creds=nil)
      parsed, creds = request(:get, url+"/#{auth_provider_id}/authorize", api_creds, attribs)
      if parsed[:errors].any?
        raise Error, parsed[:errors].inspect
      end
      parsed[:data][:url]
    end

    # same as self.authorize_url(self.id, ...)
    def authorize_url(attribs={})
      self.class.authorize_url(id, attribs, api_creds)
    end

    # attribs - :code  - required
    #         - :nonce - optional
    #         - :state - required
    # always returns a new object; check .errors? or .valid? to see how it went
    def self.authorize(attribs={}, api_creds=nil)
      parsed, creds = request(:post, url+'/authorize', api_creds, attribs)
      User.new(parsed, creds)
    end

  end
end
