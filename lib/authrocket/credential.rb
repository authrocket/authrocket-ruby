module AuthRocket
  class Credential < Resource
    crud :find, :create, :update, :delete

    belongs_to :auth_provider
    belongs_to :user

    attr :credential_type
    attr :api_key
    attr :password, :password_confirmation
    attr :access_token, :provider_user_id, :token_expires_at

  end
end
