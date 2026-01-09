module AuthRocket
  class Event < Resource
    crud :all, :find

    belongs_to :auth_provider
    belongs_to :invitation
    belongs_to :membership
    belongs_to :org
    belongs_to :realm
    belongs_to :user
    has_many :notifications

    attr :event_type, :session_id, :token
    attr_datetime :event_at, :expires_at

    def request_data
      self[:request]
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
