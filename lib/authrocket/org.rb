module AuthRocket
  class Org < Resource
    crud :all, :find, :create, :update, :delete

    belongs_to :realm
    has_many :events
    has_many :memberships

    attr :realm_id, :name, :state, :reference
    attr_datetime :created_at


    def users
      memberships.map(&:user).compact
    end

    def find_user(uid)
      users.detect{|u| u.id == uid } || raise(RecordNotFound)
    end

  end
end
