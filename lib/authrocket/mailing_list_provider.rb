module AuthRocket
  class MailingListProvider < Resource
    crud :all, :find, :create, :update, :delete

    belongs_to :realm

    attr :provider_name, :provider_type, :state
    attr :api_endpoint, :provider_account, :valid_list_ids

  end
end
