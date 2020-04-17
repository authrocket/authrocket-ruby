module AuthRocket
  class Connection < Resource
    crud :all, :find, :create, :update, :delete

    belongs_to :realm

    attr :connection_name, :connection_type, :state
    attr :email_from, :email_from_name
    attr :smtp_host, :smtp_password, :smtp_port, :smtp_user
    attr :api_endpoint, :provider_account, :valid_list_ids

  end
end
