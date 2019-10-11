module AuthRocket
  class Invitation < Resource
    crud :all, :find, :create, :update, :delete

    belongs_to :inviting_user, 'AuthRocket::User'
    belongs_to :org
    belongs_to :realm
    has_many :events

    attr :email, :invitation_type, :token
    attr :permissions
    attr_datetime :created_at, :expires_at, :invited_at

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

    def invite(attribs={})
      params = parse_request_params(attribs, json_root: json_root).reverse_merge credentials: api_creds
      parsed, _ = request(:post, url+'/invite', params)
      load(parsed)
      errors.empty? ? self : false
    end

  end
end
