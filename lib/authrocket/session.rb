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
      raise Error, "missing :jwt_key (or AUTHROCKET_JWT_KEY)" unless secret
      return unless token

      algo = options[:algo]
      if secret.is_a?(String) && secret.length > 256
        secret = OpenSSL::PKey.read secret
      end
      algo ||= 'RS256' if secret.is_a?(OpenSSL::PKey::RSA)
      algo ||= 'HS256'

      jwt, _ = JWT.decode token, secret, true, algorithm: algo

      if within = options.delete(:within)
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
              user_id: jwt['sub'],
              org_id: m['oid'],
              org: Org.new({
                id: m['oid'],
                realm_id: jwt['rid'],
                name: m['name'],
                reference: m['ref'],
                custom: m['cs'],
              }),
            })
          end,
        }, options[:credentials])
      session = new({
          id: jwt['sid'],
          created_at: jwt['iat'],
          expires_at: jwt['exp'],
          token: token,
          user_id: jwt['sub'],
          user: user
        }, options[:credentials])
      
      session
    rescue JWT::DecodeError
      nil
    end

  end
end
