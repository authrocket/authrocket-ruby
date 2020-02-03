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
    def self.from_token(token, options={})
      secret = options.dig(:credentials, :jwt_key) || credentials[:jwt_key]
      if lr_url = options.dig(:credentials, :loginrocket_url) || credentials[:loginrocket_url]
        lr_url = lr_url.dup
        lr_url.concat '/' unless lr_url.ends_with?('/')
        lr_url.concat 'connect/jwks'
      end

      algo = options[:algo]
      if secret.is_a?(String) && secret.length > 256
        unless secret.starts_with?('-----BEGIN ')
          secret = "-----BEGIN PUBLIC KEY-----\n#{secret}\n-----END PUBLIC KEY-----"
        end
        secret = OpenSSL::PKey.read secret
      end
      algo ||= 'RS256' if secret.is_a?(OpenSSL::PKey::RSA)
      algo ||= 'HS256' if secret

      jwks_eligible = algo.in?([nil, 'RS256']) && secret.blank? && lr_url

      raise Error, "Missing jwt_key; set LOGINROCKET_URL, AUTHROCKET_JWT_KEY, or pass in credentials: {loginrocket_url: ...} or {jwt_key: ...}" if secret.blank? && !jwks_eligible
      return if token.blank?

      if jwks_eligible
        base_params = {token: token, algo: 'RS256', within: options[:within], local_creds: options[:credentials]}
        load_jwk_set(lr_url, use_cached: true).each do |secret|
          begin
            return parse_jwt secret: secret, **base_params
          rescue JWT::DecodeError
          end
        end
        load_jwk_set(lr_url, use_cached: false).each do |secret|
          begin
            return parse_jwt secret: secret, **base_params
          rescue JWT::DecodeError
          end
        end
        nil
      else
        begin
          parse_jwt token: token, secret: secret, algo: algo, within: options[:within], local_creds: options[:credentials]
        rescue JWT::DecodeError
          nil
        end
      end
    end

    # private
    # raises an exception if eligible for retry using different token
    # returns Session on success
    # returns nil on a definitive token-parsed-but-invalid
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
    rescue JWT::ExpiredSignature, JWT::ImmatureSignature, JWT::InvalidAudError,
        JWT::InvalidIatError, JWT::InvalidIssuerError
      # successfully parsed, but invalid claims
      nil
    end

    @_jwks ||= {}
    JWKS_MUTEX = Mutex.new
    MIN_ATTEMPT_WINDOW = 71 # seconds

    # private
    # use_cached - if there is a cached result, use it regardless of last cache load time
    def self.load_jwk_set(uri, use_cached:)
      keys, last_time = @_jwks.dig(uri, :keys), @_jwks.dig(uri, :time)
      last_time ||= 0

      return keys if use_cached && last_time > 0
      return keys if Time.now.to_f - MIN_ATTEMPT_WINDOW < last_time

      JWKS_MUTEX.synchronize do
        # recheck in case we locked while being loaded in another process
        newer_keys, newer_time = @_jwks.dig(uri, :keys), @_jwks.dig(uri, :time)
        newer_time ||= 0

        return newer_keys if newer_time > last_time

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
        certs = parsed[:data][:keys].map do |h|
          crt = "-----BEGIN PUBLIC KEY-----\n#{h['x5c'][0]}\n-----END PUBLIC KEY-----"
          OpenSSL::PKey.read crt
        end

        @_jwks[uri] = {keys: certs, time: Time.now.to_f}
        keys ||= []
        just_added = certs - keys
        if just_added.any?
          just_added
        else
          certs
        end
      end
    end

  end
end
