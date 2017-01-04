module AuthRocket
  class UserToken < Resource
    crud :find, :create

    attr :credential_type, :email, :username
    attr :first_name, :last_name, :password, :password_confirmation

  end
end
