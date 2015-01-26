module AuthRocket
  class Credential < Resource
    crud :find, :create, :update, :delete

    belongs_to :user

    attr :api_key, :credential_type
    attr :password, :password_confirmation

  end
end
