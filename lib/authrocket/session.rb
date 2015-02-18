module AuthRocket
  class Session < Resource
    crud :all, :find, :create, :delete

    belongs_to :user

    attr :client, :ip
    attr :token # readonly
    attr_datetime :created_at, :expires_at # readonly

    # options - :within - (in seconds) Maximum time since the token was originally issued
    def self.from_token(token, options={}, api_creds=nil)
      secret = (api_creds||credentials)[:jwt_secret]
      raise Error, "missing :jwt_secret (or AUTHROCKET_JWT_SECRET)" unless secret
      return unless token

      jwt, _ = JWT.decode token, secret

      if within = options.delete(:within)
        return if jwt['iat'] < Time.now.to_i - within
      end

      user = User.new({
          id: jwt['uid'],
          username: jwt['un'],
          first_name: jwt['fn'],
          last_name: jwt['ln'],
          name: jwt['n'],
          memberships: jwt['m'] && jwt['m'].map do |m|
            Membership.new({
              permissions: m['p'],
              user_id: jwt['uid'],
              org_id: m['oid'],
              org: m['oid'] && Org.new({
                id: m['oid'],
                name: m['o'],
              }),
            })
          end,
        }, api_creds)
      session = new({
          id: jwt['tk'],
          created_at: jwt['iat'],
          expires_at: jwt['exp'],
          token: token,
          user_id: jwt['uid'],
          user: user
        }, api_creds)
      
      session
    rescue JWT::DecodeError, JWT::ExpiredSignature
      nil
    end

  end
end
