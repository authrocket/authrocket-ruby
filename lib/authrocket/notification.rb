module AuthRocket
  class Notification < Resource

    belongs_to :event
    belongs_to :hook

    attr :attempts, :hook_type, :last_destination, :last_result, :state
    attr_datetime :last_attempt_at

  end
end
