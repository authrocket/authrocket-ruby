module AuthRocket
  class Domain < Resource
    crud :all, :find, :create, :update, :delete

    belongs_to :realm

    attr :cert_state, :dns_state, :domain_type, :flags, :fqdn, :state
    attr :subdomain
    attr :domain

    def verify(attribs={})
      params = parse_request_params(attribs, json_root: json_root).reverse_merge credentials: api_creds
      parsed, _ = request(:post, resource_path+'/verify', params)
      load(parsed)
      errors.empty? ? self : false
    end

  end
end
