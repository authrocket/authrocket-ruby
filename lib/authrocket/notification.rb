module AuthRocket
  class Notification < Resource

    belongs_to :app_hook
    belongs_to :event

    attr :attempts, :last_destination, :last_result, :state
    attr_datetime :last_attempt_at

  end
end
