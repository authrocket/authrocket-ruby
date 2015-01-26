module AuthRocket
  class User < Resource
    crud :all, :find, :create, :update, :delete

    belongs_to :realm
    has_many :credentials
    has_many :events
    has_many :memberships

    attr :api_key # deprecated
    attr :custom, :email, :first_name
    attr :last_name, :name, :password, :password_confirmation
    attr :reference, :state, :user_type, :username
    attr_datetime :created_at, :last_login_at
    attr_datetime :last_login_on # deprecated


    def credentials
      reload unless @attribs[:credentials]
      @attribs[:credentials]
    end

    def orgs
      memberships.map(&:org).compact
    end

    def find_org(id)
      orgs.detect{|o| o.id == id } || raise(RecordNotFound)
    end

    def human? ; user_type=='human' ; end
    def api?   ; user_type=='api'   ; end


    class << self

      def authenticate(username, password, params={}, api_creds=nil)
        params = params.merge(password: password)
        parsed, creds = request(:post, "#{url}/#{CGI.escape username}/authenticate", api_creds, params)
        if parsed[:errors].any?
          raise ValidationError, parsed[:errors]
        end
        new(parsed, creds)
      end

      def authenticate_key(api_key, params={}, api_creds=nil)
        params = params.merge(api_key: api_key)
        parsed, creds = request(:post, "#{url}/authenticate_key", api_creds, params)
        if parsed[:errors].any?
          raise ValidationError, parsed[:errors]
        end
        new(parsed, creds)
      end

      def generate_password_token(username, params={}, api_creds=nil)
        parsed, creds = request(:post, "#{url}/#{CGI.escape username}/generate_password_token", api_creds, params)
        if parsed[:errors].any?
          raise ValidationError, parsed[:errors]
        end
        new(parsed, creds)
      end

      def reset_password_with_token(username, token, new_pw, new_pw_2, params={}, api_creds=nil)
        params = params.with_indifferent_access.merge(user: {token: token, password: new_pw, password_confirmation: new_pw_2})
        parsed, creds = request(:post, "#{url}/#{CGI.escape username}/reset_password_with_token", api_creds, params)
        if parsed[:errors].any?
          raise ValidationError, parsed[:errors]
        end
        new(parsed, creds)
      end

    end

    # params - {current_password: 'old', password: 'new', password_confirmation: 'new'}
    def update_password(params)
      params = {user: params}
      parsed, _ = request(:put, "#{url}/update_password", api_creds, params)
      load(parsed)
      errors.empty? ? self : false
    end


  end
end
