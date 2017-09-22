module AuthRocket
  class Credential < Resource
    crud :find, :create, :update, :delete

    belongs_to :auth_provider
    belongs_to :user

    attr :credential_type
    attr :api_key
    attr :password, :password_confirmation
    attr :name, :otp_secret, :provisioning_uri, :state
    attr :access_token, :provider_user_id, :token_expires_at


    # code - required
    def verify(code, attribs={})
      params = parse_request_params(attribs.merge(code: code), json_root: json_root).merge credentials: api_creds
      parsed, _ = request(:post, url+'/verify', params)
      load(parsed)
      errors.empty? ? self : false
    end

  end
end
