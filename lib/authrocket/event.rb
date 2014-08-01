module AuthRocket
  class Event < Resource
    crud :all, :find

    belongs_to :app_hook
    belongs_to :login_policy
    belongs_to :membership
    belongs_to :org
    belongs_to :realm
    belongs_to :user

    attr :event_type, :ip
    attr_datetime :event_at


    def self.validate_token(token, params={}, api_creds=nil)
      parsed, creds = request(:get, "#{url}/login/#{CGI.escape token}", api_creds, params)
      new(parsed, creds)
    rescue RecordNotFound
      nil
    end

  end
end
