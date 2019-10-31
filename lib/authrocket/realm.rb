module AuthRocket
  class Realm < Resource
    crud :all, :find, :create, :update, :delete

    has_many :auth_providers
    has_many :client_apps
    has_many :connections
    has_many :domains
    has_many :events
    has_many :hooks
    has_many :invitations
    has_many :jwt_keys
    has_many :named_permissions
    has_many :orgs
    has_many :resource_links
    has_many :users

    attr :custom, :environment, :name, :public_name, :state
    attr :email_verification, :org_mode, :signup
    attr :name_field, :org_name_field, :password_field, :username_field
    attr :branding, :color_1, :logo, :stylesheet
    attr :access_token_minutes, :jwt_algo, :jwt_minutes, :jwt_scopes, :session_minutes
    attr :jwt_key # readonly


    def named_permissions
      reload unless @attribs[:named_permissions]
      @attribs[:named_permissions]
    end

    def resource_links
      reload unless @attribs[:resource_links]
      @attribs[:resource_links]
    end


    def reset!(params={})
      params = parse_request_params(params).reverse_merge credentials: api_creds
      parsed, _ = request(:post, "#{resource_path}/reset", params)
      load(parsed)
      errors.empty? ? self : false
    end

  end
end
