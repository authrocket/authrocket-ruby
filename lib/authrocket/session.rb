require 'openssl'
require 'jwt'

module AuthRocket
  class Session < Resource
    crud :all, :find, :create, :delete

    belongs_to :client_app
    belongs_to :user

    attr :token # readonly
    attr_datetime :created_at, :expires_at

    def request_data
      self[:request]
    end


    # options - :algo   - one of HS256, RS256 (default: auto-detect based on :jwt_key)
    #         - :within - (in seconds) Maximum time since the token was (re)issued
    #         - credentials: {jwt_key: StringOrKey} - used to verify the token
    # returns Session or nil
    def self.from_token(token, options={})
      if lr_url = options.dig(:credentials, :loginrocket_url) || credentials[:loginrocket_url]
        lr_url = lr_url.dup
        lr_url.concat '/' unless lr_url.ends_with?('/')
        lr_url.concat 'connect/jwks'
      end
      secret = options.dig(:credentials, :jwt_key) || credentials[:jwt_key]
      if secret.is_a?(String) && secret.length > 256
        unless secret.starts_with?('-----BEGIN ')
          secret = "-----BEGIN PUBLIC KEY-----\n#{secret}\n-----END PUBLIC KEY-----"
        end
        secret = OpenSSL::PKey.read secret
      end
      algo = options[:algo]
      algo ||= 'RS256' if secret.is_a?(OpenSSL::PKey::RSA)
      algo ||= 'HS256' if secret

      jwks_eligible = algo.in?([nil, 'RS256']) && secret.blank? && lr_url

      raise Error, "Missing jwt_key; set LOGINROCKET_URL, AUTHROCKET_JWT_KEY, or pass in credentials: {loginrocket_url: ...} or {jwt_key: ...}" if secret.blank? && !jwks_eligible
      return if token.blank?

      base_params = {token: token, within: options[:within], local_creds: options[:credentials]}
      if jwks_eligible
        kid = JSON.parse(JWT::Base64.url_decode(token.split('.')[0]))['kid'] rescue nil
        return if kid.blank?

        load_jwk_set(lr_url) unless @_jwks[kid]
        if key_set = @_jwks[kid]
          parse_jwt **key_set, **base_params
        end
      else
        parse_jwt secret: secret, algo: algo, **base_params
      end
    end

    # private
    # returns Session or nil
    def self.parse_jwt(token:, secret:, algo:, within:, local_creds: nil)
      opts = {
        algorithm: algo,
        leeway: 5,
        iss: "https://authrocket.com",
        verify_iss: true,
      }

      jwt, _ = JWT.decode token, secret, true, opts

      if within
        # this ensures token was created recently
        # :iat is set to Time.now every time a token is created by the AR api
        return if jwt['iat'] < Time.now.to_i - within
      end

      user = User.new({
          id: jwt['sub'],
          realm_id: jwt['rid'],
          username: jwt['preferred_username'],
          first_name: jwt['given_name'],
          last_name: jwt['family_name'],
          name: jwt['name'],
          email: jwt['email'],
          email_verification: jwt['email_verified'] ? 'verified' : 'none',
          reference: jwt['ref'],
          custom: jwt['cs'],
          memberships: jwt['orgs'] && jwt['orgs'].map do |m|
            Membership.new({
              id: m['mid'],
              permissions: m['perm'],
              selected: m['selected'],
              user_id: jwt['sub'],
              org_id: m['oid'],
              org: Org.new({
                id: m['oid'],
                realm_id: jwt['rid'],
                name: m['name'],
                reference: m['ref'],
                custom: m['cs'],
              }, local_creds),
            }, local_creds)
          end,
        }, local_creds)
      session = new({
          id: jwt['sid'],
          created_at: jwt['iat'],
          expires_at: jwt['exp'],
          token: token,
          user_id: jwt['sub'],
          user: user
        }, local_creds)

      session
    rescue JWT::DecodeError
      nil
    end

    @_jwks ||= {}
    JWKS_MUTEX = Mutex.new

    # private
    def self.load_jwk_set(uri)
      JWKS_MUTEX.synchronize do
        path = URI.parse(uri).path
        headers = build_headers({}, {})
        rest_opts = {
          connect_timeout: 8,
          headers: headers,
          method: :get,
          path: path,
          read_timeout: 15,
          url: uri,
          write_timeout: 15,
        }
        response = execute_request(rest_opts)
        parsed = parse_response(response)
          # => {data: json, errors: errors, metadata: metadata}
        parsed[:data][:keys].each do |h|
          crt = "-----BEGIN PUBLIC KEY-----\n#{h['x5c'][0]}\n-----END PUBLIC KEY-----"
          @_jwks[h['kid']] = {secret: OpenSSL::PKey.read(crt), algo: h['alg']}
        end
      end
      @_jwks
    end

  end
end
