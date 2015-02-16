module AuthRocket
  class AppHook < Resource
    crud :all, :find, :create, :update, :delete

    belongs_to :realm
    has_many :events

    attr :event_type, :hook_type, :destination, :email_from, :user_type, :email_subject, :email_template

    def self.event_types
      %w( *
          realm.*  realm.created  realm.updated  realm.deleted
          user.*  user.created  user.updated  user.deleted
            user.login.*  user.login.succeeded  user.login.failed
            user.password_token.*  user.password_token.created  user.password_token.consumed  user.password_token.failed
          org.*  org.created  org.updated  org.deleted
          membership.*  membership.created  membership.updated  membership.deleted
          app_hook.*  app_hook.created  app_hook.updated  app_hook.deleted
          auth_provider.* auth_provider.created auth_provider.updated auth_provider.deleted
          login_policy.*  login_policy.created  login_policy.updated  login_policy.deleted
        ).sort
    end


  end
end
