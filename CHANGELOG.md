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
