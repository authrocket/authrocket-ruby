module AuthRocket
  class Realm < Resource
    crud :all, :find, :create, :update, :delete

    has_many :app_hooks
    has_many :auth_providers
    has_many :events
    has_many :login_policies
    has_many :orgs
    has_many :users

    attr :api_key_minutes, :api_key_policy, :api_key_prefix, :custom, :name
    attr :jwt_data, :require_unique_emails, :session_minutes, :session_type
    attr :state, :username_validation_human
    attr :jwt_secret # readonly


    def reset!(params={})
      params = parse_request_params(params).merge credentials: api_creds
      parsed, _ = request(:post, "#{url}/reset", params)
      load(parsed)
      errors.empty? ? self : false
    end

  end
end
