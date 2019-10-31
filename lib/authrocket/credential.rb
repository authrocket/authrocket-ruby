module AuthRocket
  class Credential < Resource
    crud :find, :create, :update, :delete

    belongs_to :auth_provider
    belongs_to :client_app
    belongs_to :user

    attr :credential_type
    attr :password, :password_confirmation # writeonly
    attr :name, :otp_secret, :provisioning_svg, :provisioning_uri, :state
    attr :access_token, :provider_user_id
    attr_datetime :token_expires_at
    attr :client_app_name, :approved_scopes


    def provisioning_svg
      self[:provisioning_svg]&.html_safe
    end

    # code - required
    def verify(code, attribs={})
      params = parse_request_params(attribs.merge(code: code), json_root: json_root).reverse_merge credentials: api_creds
      parsed, _ = request(:post, resource_path+'/verify', params)
      load(parsed)
      errors.empty? ? self : false
    end

  end
end
