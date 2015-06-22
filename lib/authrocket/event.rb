module AuthRocket
  class Event < Resource
    crud :all, :find

    belongs_to :app_hook
    belongs_to :auth_provider
    belongs_to :login_policy
    belongs_to :membership
    belongs_to :org
    belongs_to :realm
    belongs_to :user
    has_many :notifications

    attr :event_type, :ip
    attr_datetime :event_at


    # deprecated - use Session.from_token() or Session.find()
    def self.validate_token(token, params={}, api_creds=nil)
      parsed, creds = request(:get, "#{url}/login/#{CGI.escape token}", api_creds, params)
      new(parsed, creds)
    rescue RecordNotFound
      nil
    end

    def notifications
      reload unless @attribs[:notifications]
      unless @stuffed_event
        @attribs[:notifications].each do |n|
          n.send :load, data: {event: self, event_id: id}
        end
        @stuffed_event = true
      end
      @attribs[:notifications]
    end

    def find_notification(nid)
      notifications.detect{|n| n.id == nid} || raise(RecordNotFound)
    end

  end
end
