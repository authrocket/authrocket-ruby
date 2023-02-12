module AuthRocket
  class Hook < Resource
    crud :all, :find, :create, :update, :delete

    belongs_to :realm
    belongs_to :connection

    attr :accumulate, :delay, :event_type, :hook_type, :state
    attr :destination
    attr :email_renderers, :email_subjects, :email_templates, :email_to, :locales
    attr :current_locales # readonly
    attr :description, :list_id, :name, :on_create, :visibility


    def self.event_types
      %w( invitation.org.created  invitation.org.updated  invitation.org.invited  invitation.org.accepted  invitation.org.expired
          invitation.preverify.created  invitation.preverify.updated  invitation.preverify.invited  invitation.preverify.accepted  invitation.preverify.expired
          invitation.referral.created  invitation.referral.updated  invitation.referral.invited  invitation.referral.accepted  invitation.referral.expired
          invitation.request.created  invitation.request.updated  invitation.request.invited  invitation.request.accepted  invitation.request.expired
          membership.created  membership.updated  membership.deleted
          org.created  org.updated  org.closed
          user.created  user.updated  user.deleted
            user.email.updating  user.email.verifying  user.email.verified
            user.login.succeeded  user.login.failed  user.login.initiated
            user.password.resetting  user.password.updated
            user.profile.updated
        ).sort
    end

    def self.email_event_types
      %w( invitation.org.invited  invitation.org.accepted
            invitation.preverify.invited
            invitation.referral.invited
            invitation.request.invited
          user.created
            user.email.updating  user.email.verifying  user.email.verified
            user.login.succeeded  user.login.failed
            user.password.resetting  user.password.updated
            user.profile.updated
        ).sort
    end

  end
end
