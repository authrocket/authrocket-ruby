module AuthRocket
  class Membership < Resource
    crud :all, :find, :create, :update, :delete

    belongs_to :org
    belongs_to :user
    has_many :events

    attr :custom
    attr_datetime :expires_at


    def any_permission?(*perms)
      perms.any? do |p|
        case p
        when String
          permissions.include? p
        when Regexp
          permissions.any?{|m| p =~ m}
        else
          false
        end
      end
    end

  end
end
