module AuthRocket
  class JwtKey < Resource
    crud :all, :find, :create, :delete

    belongs_to :realm

    attr :algo, :key, :use
    attr :flags, :short_key # readonly

  end
end
