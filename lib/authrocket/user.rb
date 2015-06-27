module AuthRocket
  class User < Resource
    crud :all, :find, :create, :update, :delete

    belongs_to :realm
    has_many :credentials
    has_many :events
    has_many :memberships
    has_many :sessions

    attr :custom, :email, :first_name
    attr :last_name, :name, :password, :password_confirmation
    attr :reference, :state, :user_type, :username
    attr_datetime :created_at, :last_login_at


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

      def authenticate(username, password, params={})
        params = parse_request_params(params).merge password: password
        parsed, creds = request(:post, "#{url}/#{CGI.escape username}/authenticate", params)
        if parsed[:errors].any?
          raise ValidationError, parsed[:errors]
        end
        new(parsed, creds)
      end

      def authenticate_key(api_key, params={})
        params = parse_request_params(params).merge api_key: api_key
        parsed, creds = request(:post, "#{url}/authenticate_key", params)
        if parsed[:errors].any?
          raise ValidationError, parsed[:errors]
        end
        new(parsed, creds)
      end

      def generate_password_token(username, params={})
        params = parse_request_params(params)
        parsed, creds = request(:post, "#{url}/#{CGI.escape username}/generate_password_token", params)
        if parsed[:errors].any?
          raise ValidationError, parsed[:errors]
        end
        new(parsed, creds)
      end

      # params - {username: '...', token: '...', password: '...', password_confirmation: '...'}
      def reset_password_with_token(params)
        params = parse_request_params(params, json_root: json_root)
        username = params[json_root].delete(:username) || '--'
        parsed, creds = request(:post, "#{url}/#{CGI.escape username}/reset_password_with_token", params)
        if parsed[:errors].any?
          raise ValidationError, parsed[:errors]
        end
        new(parsed, creds)
      end

    end

    # params - {current_password: 'old', password: 'new', password_confirmation: 'new'}
    def update_password(params)
      params = parse_request_params(params, json_root: json_root).merge credentials: api_creds
      parsed, _ = request(:put, "#{url}/update_password", params)
      load(parsed)
      errors.empty? ? self : false
    end


  end
end
