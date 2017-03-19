module AuthRocket
  include NCore::Builder
  Resource.send :include, AuthRocket::Client
  SingletonResource.send :include, AuthRocket::Client

  configure do
    self.default_url = ENV['AUTHROCKET_URL']

    self.default_headers = {
      accept: 'application/json',
      content_type: 'application/json',
      user_agent: "AuthRocket/ruby v#{VERSION} [nc #{NCore::VERSION}]"
    }

    if ENV['AUTHROCKET_URI']
      self.credentials = parse_credentials ENV['AUTHROCKET_URI']
    elsif ENV['AUTHROCKET_API_KEY']
      self.credentials = {
        api_key: ENV['AUTHROCKET_API_KEY'],
        account: ENV['AUTHROCKET_ACCOUNT'],
        realm:   ENV['AUTHROCKET_REALM'],
        jwt_secret: ENV['AUTHROCKET_JWT_SECRET']
      }
    end

    self.debug = false

    self.strict_attributes = true


    self.instrument_key = 'request.authrocket'

    self.status_page = 'http://status.authrocket.com/'

    self.auth_header_prefix = 'X-Authrocket'

    self.credentials_error_message = %Q{Missing API credentials or URL. Set default credentials using "AuthRocket::Api.credentials = {api_key: YOUR_API_KEY, url: AR_REGION_URL}"}
  end


  class << self
    # makes AuthRocket::Realm.model_name.param_key do the right thing
    def use_relative_model_naming?
      true
    end


    private

    def parse_credentials(creds)
      case creds
      when String
        url = URI.parse creds rescue nil
        if url
          o = {}
          [url.password, url.user].each do |part|
            case part
            when /^jsk_/
              o[:jwt_secret] = part
            when /^k(ey|o)_/
              o[:api_key] = part
            when /^org_/
              o[:account] = part
            when /^rl_/
              o[:realm] = part
            end
          end
          url.user = url.password = nil
          o[:url] = url.to_s
          o
        else
          raise Error, 'Unable to parse AuthRocket credentials URI'
        end

      when NilClass
        {}
      else
        creds
      end.with_indifferent_access
    end

  end
end
