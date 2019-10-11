module AuthRocket
  class NamedPermission < Resource
    crud :find, :create, :update, :delete

    belongs_to :realm

    attr :auto_grant, :name, :permission

  end
end
