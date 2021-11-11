#### 3.4.0

- Document how to change locales
- Self-configure rescue_responses when using Rails

#### 3.3.0

- Update Invitation, Hook, Realm, User

#### 3.2.1

- Update AuthProvider

#### 3.2.0

- Add HookState
- Update Connection, Hook

#### 3.1.0

- Automatically handle login tokens in an Authorization header
  eg: Authorization: Bearer {the-token}
- Optimize LR JWKS support to match by kid

#### 3.0.0

- NOTE: This version includes breaking changes.
  It is only compatible with AuthRocket 2. Use gem version '~> 2.0' with AuthRocket 1.
- Refactor Rails integration
- Update resources for AuthRocket 2
  - Add: ClientApp, Connection, Domain, Invitation, NamedPermission, Oauth2Session, ResourceLink, Token
  - Remove: LoginPolicy, UserToken,
  - Rename: AppHook -> Hook
  - Update most others
- Support LR JWKS - retrieve RS256 key when key not pre-configured
- Update auth/credentials
  - Rename ENV AUTHROCKET_JWT_SECRET -> AUTHROCKET_JWT_KEY
  - Rename ENV AUTHROCKET_LOGIN_URL -> LOGINROCKET_URL
  - Rename AuthRocket::API.credentials :jwt_secret -> :jwt_key
- Update ncore to v3
  - `#errors` is now always an ActiveModel::Errors instance
  - <exception>#errors is now an ActiveModel::Errors for all applicable exceptions
- Require Ruby >= 2.3

#### 2.4.1

- Require ncore 2.2.2+

#### 2.4.0

- Add Rails Engine for expedited setup

#### 2.3.1

- Properly self-configure when only using :jwt_secret

#### 2.3.0

- Add support for TOTP MFA

#### 2.2.0

- Add Realm#jwt_algo
- Deprecate Realm#jwt_secret - replaced with Realm#jwt_key
- Add JwtKey resource
- Support RS256 signed tokens

#### 2.1.1

- Add Realm#jwt_fields
- Deprecate Realm#jwt_data - replaced by #jwt_fields
- Parse custom attributes from JWT when available

#### 2.1.0

- AuthProvider.authorize, #authorize_token can now return a UserToken
- Add UserToken#credential_type

#### 2.0.3

- Fix error handling for missing jwt_secret

#### 2.0.2

- Add Realm#resource_links

#### 2.0.1

- Add Notification#hook_type

#### 2.0.0

- NOTE: This version includes breaking changes.
- Depends on ncore 2.0
  - ncore update changes most method signatures to remove the final api_creds param - use a :credentials key instead:
      Old: User.create(params, api_creds)
      New: User.create(params.merge(credentials: api_creds))
    - As api_creds is not generally needed, this should affect few people
  - No longer depends on 'multi_json', but uses it if available. Defaults to stdlib 'json'.
  - find(nil) now raises RecordNotFound instead of returning nil
- User.reset_password_with_token signature change:
  Old: reset_password_with_token(username, token, new_pw, new_pw_2, params={}, api_creds)
  New: reset_password_with_token(username: '...', token: '...', password: '...', password_confirmation: '...', ...)
- Remove previously deprecated Event.validate_token
- Remove previously deprecated LoginPolicy#enable_logins, #enable_signups, #name_field
- Remove previously deprecated User#api_key, #last_login_on
- Add Event#request_data, Session#request_data
- Remove Event#ip, Session#ip, and Session#client - use #request_data['ip'] or #request_data['client'] instead
- Add AppHook#email_from_name
- Add AuthProvider#authorize_token
- Detect new ko_ API keys
- Support email verification
- Add LoginPolicy#redirect_uris
- Fix issue with older rubies

#### 1.5.0

- Update Event and add Notification

#### 1.4.4

- Bump to jwt 1.5
- Enforce hmac algorithm for jwt
- Add AuthProvider#min_complexity, #required_chars

#### 1.4.3

- Add AuthProvider#min_length

#### 1.4.2

- Add AppHook#email_renderer

#### 1.4.1

- Bump to jwt 1.4
- Add AppHook#email_to
- Update AppHook.event_types

#### 1.4.0

- Support social auth in AuthProvider and Credential

#### 1.3.1

- Add Realm#api_key_minutes
- Add Session#client

#### 1.3.0

- Add Session resource
- Deprecate Event.validate_token - Replaced by Session.from_token and Session.find
- Add missing auth_provider.* events

#### 1.2.0

- Add Credential resource
- Deprecate User#api_key - Replaced by Credential#api_key
- Add AuthProvider resource
- Deprecate LoginPolicy#enable_logins, #enable_signups, and #name_field - Replaced by AuthProvider#login, #signup, and #name_field where #provider_type is 'login_rocket'

#### 1.1.0

- Add custom attributes for Membership, Org, Realm, User

#### 1.0.1

- Change User#last_login_on -> #last_login_at

#### 1.0.0

- Initial release
