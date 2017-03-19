require 'openssl'
require 'jwt'

module AuthRocket
  class Session < Resource
    crud :all, :find, :create, :delete

    belongs_to :user

    attr :token # readonly
    attr_datetime :created_at, :expires_at # readonly

    def request_data
      self[:request]
    end


    # options - :within - (in seconds) Maximum time since the token was originally issued
    #         - credentials: {jwt_secret: StringOrKey} - used to verify the token
    #         - :algo - one of HS256, RS256 (default: auto-detect based on :jwt_secret)
    def self.from_token(token, options={})
      secret = (options[:credentials]||credentials||{})[:jwt_secret]
      raise Error, "missing :jwt_secret (or AUTHROCKET_JWT_SECRET)" unless secret
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
          id: jwt['uid'],
          realm_id: jwt['aud'],
          username: jwt['un'],
          first_name: jwt['fn'],
          last_name: jwt['ln'],
          name: jwt['n'],
          custom: jwt['cs'],
          memberships: jwt['m'] && jwt['m'].map do |m|
            Membership.new({
              permissions: m['p'],
              custom: m['cs'],
              user_id: jwt['uid'],
              org_id: m['oid'],
              org: m['o'] && Org.new({
                id: m['oid'],
                realm_id: jwt['aud'],
                name: m['o'],
                custom: m['ocs'],
              }),
            })
          end,
        }, options[:credentials])
      session = new({
          id: jwt['tk'],
          created_at: jwt['iat'],
          expires_at: jwt['exp'],
          token: token,
          user_id: jwt['uid'],
          user: user
        }, options[:credentials])
      
      session
    rescue JWT::DecodeError
      nil
    end

  end
end
