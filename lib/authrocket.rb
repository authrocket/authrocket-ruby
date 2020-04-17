require 'addressable/uri'
require 'ncore'
require 'jwt'

%w(version client api_config).each do |f|
  require "authrocket/api/#{f}"
end

%w(
  auth_provider
  client_app
  connection
  credential
  domain
  event
  hook
  hook_state
  invitation
  jwt_key
  membership
  named_permission
  notification
  oauth2_session
  org
  realm
  resource_link
  session
  token
  user
).each do |f|
  require "authrocket/#{f}"
end

require 'authrocket/api/railtie' if defined?(Rails)
