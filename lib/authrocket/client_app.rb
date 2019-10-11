module AuthRocket
  class ClientApp < Resource
    crud :all, :find, :create, :update, :delete

    belongs_to :realm

    attr :client_type, :name, :redirect_uris
    # standard:
    attr :state
    # oauth2:
    attr :allowed_scopes, :app_type, :logo, :secret, :trusted

  end
end
