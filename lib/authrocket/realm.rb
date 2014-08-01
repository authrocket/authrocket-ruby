module AuthRocket
  class Realm < Resource
    crud :all, :find, :create, :update, :delete

    has_many :app_hooks
    has_many :events
    has_many :login_policies
    has_many :orgs
    has_many :users

    attr :api_key_policy, :api_key_prefix, :name, :require_unique_emails, :state
    attr :username_validation_human


    def reset!(params={})
      parsed, _ = request(:post, "#{url}/reset", api_creds, params)
      load(parsed)
      errors.empty? ? self : false
    end

  end
end
