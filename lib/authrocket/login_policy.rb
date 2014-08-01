module AuthRocket
  class LoginPolicy < Resource
    crud :all, :find, :create, :update, :delete

    belongs_to :realm
    has_many :events

    attr :custom_domains, :enable_logins, :enable_signups, :external_css
    attr :footer, :header, :login_handler, :name, :name_field, :primary_domain
    attr :signup_handler, :subdomain
    attr :base_domain, :domains # readonly

  end
end
