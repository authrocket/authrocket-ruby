module AuthRocket
  class Token < Resource

    belongs_to :user

    attr :token

  end
end
