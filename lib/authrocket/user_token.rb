module AuthRocket
  class UserToken < Resource
    crud :find, :create

    attr :username
    attr :first_name, :last_name, :password, :password_confirmation
    attr :email

  end
end
