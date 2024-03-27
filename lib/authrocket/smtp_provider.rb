module AuthRocket
  class SmtpProvider < Resource
    crud :all, :find, :create, :update, :delete

    belongs_to :realm

    attr :provider_name, :provider_type, :state
    attr :email_from, :email_from_name
    attr :smtp_host, :smtp_password, :smtp_port, :smtp_user

  end
end
