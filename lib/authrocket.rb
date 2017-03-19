require 'ncore'
require 'jwt'

%w(version client api_config).each do |f|
  require "authrocket/api/#{f}"
end

%w(app_hook auth_provider credential event jwt_key login_policy membership notification org realm session user user_token).each do |f|
  require "authrocket/#{f}"
end

require 'authrocket/api/railtie' if defined?(Rails)
