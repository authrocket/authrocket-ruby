module AuthRocket
  class Oauth2Session < Resource
    crud :find, :create

    attr :access_token, :code, :id_token, :redirect_uri
    attr :profile
    attr :expires_in, :token_type
    attr_datetime :expires_at

    def self.json_root ; 'session' ; end
    def self.resource_path ; 'sessions/oauth2' ; end

    class << self

      # params - {client_app_id:, client_app_secret:, code:}
      # returns: Token - must check .valid? or .errors? on response
      def code_to_token(params={})
        params = parse_request_params(params, json_root: json_root)
        parsed, creds = request(:post, "#{resource_path}/code", params)
        factory(parsed, creds)
      end

    end

  end
end
