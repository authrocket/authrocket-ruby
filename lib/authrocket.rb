require 'ncore'

%w(version api_config).each do |f|
  require "authrocket/api/#{f}"
end

%w(app_hook auth_provider credential event login_policy membership org realm user user_token).each do |f|
  require "authrocket/#{f}"
end

require 'authrocket/api/railtie' if defined?(Rails)
