module AuthRocket
  class AuthProvider < Resource
    crud :all, :find, :create, :update, :delete

    belongs_to :realm

    attr :provider_type
    attr :login, :name_field, :signup

  end
end
