module AuthRocket
  class ResourceLink < Resource
    crud :find, :create, :update, :delete

    belongs_to :realm

    attr :link_url, :resource_type, :title

  end
end
