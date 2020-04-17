module AuthRocket
  class HookState < Resource
    crud :all, :find, :create, :update, :delete

    belongs_to :hook
    belongs_to :user

    attr :hook_state_type
    attr :list_state


    private

    def create(attribs={})
      if self[:user_id]
        if attribs.key? json_root
          attribs[json_root][:user_id] ||= self[:user_id]
        else
          attribs[:user_id] ||= self[:user_id]
        end
      end
      super attribs
    end

  end
end
