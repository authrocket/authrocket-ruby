module AuthRocket
  class Connection < Resource
    crud :all, :find, :create, :update, :delete

    belongs_to :realm

    attr :connection_type
    attr :smtp_host, :smtp_password, :smtp_port, :smtp_user

  end
end
