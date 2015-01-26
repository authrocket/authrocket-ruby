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