module AuthRocket
  class Org < Resource
    crud :all, :find, :create, :update, :delete

    belongs_to :realm
    has_many :events
    has_many :invitations
    has_many :memberships

    attr :custom, :name, :reference, :state
    attr_datetime :created_at


    def users
      memberships.map(&:user)
    end

    def find_user(uid)
      users.detect{|u| u.id == uid } || raise(RecordNotFound)
    end

  end
end
