module AuthRocket
  class AppHook < Resource
    crud :all, :find, :create, :update, :delete

    belongs_to :realm
    has_many :events

    attr :event_type, :hook_type, :destination
    attr :email_from, :email_from_name, :email_renderer, :email_subject
    attr :email_template, :email_to, :user_type

    def self.event_types
      %w( app_hook.created  app_hook.updated  app_hook.deleted
          auth_provider.created auth_provider.updated auth_provider.deleted
          login_policy.created  login_policy.updated  login_policy.deleted
          membership.created  membership.updated  membership.deleted
          org.created  org.updated  org.deleted
          realm.created  realm.updated  realm.deleted
          user.created  user.updated  user.deleted
            user.email.verification_requested  user.email.verified
            user.login.succeeded  user.login.failed  user.login.initiated
            user.password_token.created  user.password_token.consumed  user.password_token.failed
        ).sort
    end


  end
end
