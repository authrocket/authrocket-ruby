module AuthRocket
  class JwtKey < Resource
    crud :all, :find, :create, :delete

    belongs_to :realm

    attr :algo, :key, :use
    attr :expired # readonly

  end
end
