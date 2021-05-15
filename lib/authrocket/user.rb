module AuthRocket
  class User < Resource
    crud :all, :find, :create, :update, :delete

    belongs_to :realm
    has_many :credentials
    has_many :events
    has_many :hook_states
    has_many :memberships
    has_many :sessions

    attr :custom, :email, :email_verification, :first_name, :last_name, :locale, :name
    attr :reference, :state, :username
    attr :password, :password_confirmation # writeonly
    attr_datetime :created_at, :last_login_at


    def credentials
      reload unless @attribs[:credentials]
      @attribs[:credentials]
    end

    def orgs
      memberships.map(&:org)
    end

    def find_org(id)
      orgs.detect{|o| o.id == id } || raise(RecordNotFound)
    end


    class << self
      # id - email|username|id

      # params - {password: '...'}
      # returns: Session || Token
      def authenticate(id, params)
        params = parse_request_params(params, json_root: json_root)
        parsed, creds = request(:post, "#{resource_path}/#{CGI.escape id}/authenticate", params)
        obj = factory(parsed, creds)
        raise RecordInvalid, obj if obj.errors?
        obj
      end

      # params - {token: 'kli:...', code: '000000'}
      # returns: Session
      def authenticate_token(params)
        params = parse_request_params(params, json_root: json_root)
        parsed, creds = request(:post, "#{resource_path}/authenticate_token", params)
        obj = factory(parsed, creds)
        raise RecordInvalid, obj if obj.errors?
        obj
      end

      # returns: Token
      def generate_password_token(id, params={})
        params = parse_request_params(params)
        parsed, creds = request(:post, "#{resource_path}/#{CGI.escape id}/generate_password_token", params)
        obj = factory(parsed, creds)
        raise RecordInvalid, obj if obj.errors?
        obj
      end

      # params - {token: '...', password: '...', password_confirmation: '...'}
      # returns: Session || Token
      def reset_password_with_token(params)
        params = parse_request_params(params, json_root: json_root)
        parsed, creds = request(:post, "#{resource_path}/reset_password_with_token", params)
        obj = factory(parsed, creds)
        raise RecordInvalid, obj if obj.errors?
        obj
      end

      # returns: Token
      def request_email_verification(id, params={})
        params = parse_request_params(params)
        parsed, creds = request(:post, "#{resource_path}/#{CGI.escape id}/request_email_verification", params)
        obj = factory(parsed, creds)
        raise RecordInvalid, obj if obj.errors?
        obj
      end

      # params - {token: '...'}
      # returns: User
      def verify_email(params)
        params = parse_request_params(params, json_root: json_root)
        parsed, creds = request(:post, "#{resource_path}/verify_email", params)
        obj = factory(parsed, creds)
        raise RecordInvalid, obj if obj.errors?
        obj
      end

    end


    # params - {token: '...'}
    def accept_invitation(params)
      params = parse_request_params(params, json_root: json_root).reverse_merge credentials: api_creds
      parsed, _ = request(:post, "#{resource_path}/accept_invitation", params)
      load(parsed)
      errors.empty? ? self : false
    end

    # params - {current_password: 'old', password: 'new', password_confirmation: 'new'}
    def update_password(params)
      params = parse_request_params(params, json_root: json_root).reverse_merge credentials: api_creds
      parsed, _ = request(:put, "#{resource_path}/update_password", params)
      load(parsed)
      errors.empty? ? self : false
    end

    # params - {email:, first_name:, last_name:, password:, password_confirmation:, username:}
    def update_profile(params)
      params = parse_request_params(params, json_root: json_root).reverse_merge credentials: api_creds
      parsed, _ = request(:put, "#{resource_path}/profile", params)
      load(parsed)
      errors.empty? ? self : false
    end


    # returns: Session || Token
    #   (Session.user !== self)
    def authenticate(params)
      self.class.authenticate id, params.reverse_merge(credentials: api_creds)
    rescue RecordInvalid => ex
      errors.merge! ex.errors
      false
    end

    # returns: Token
    def generate_password_token(params={})
      self.class.generate_password_token id, params.reverse_merge(credentials: api_creds)
    rescue RecordInvalid => ex
      errors.merge! ex.errors
      false
    end

    # returns: Token
    def request_email_verification(params={})
      self.class.request_email_verification id, params.reverse_merge(credentials: api_creds)
    rescue RecordInvalid => ex
      errors.merge! ex.errors
      false
    end

  end
end
