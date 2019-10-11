module AuthRocket
  class Domain < Resource
    crud :all, :find, :create, :update, :delete

    belongs_to :realm

    attr :dns_state, :domain_type, :fqdn, :state
    attr :subdomain
    attr :domain

    def verify(attribs={})
      params = parse_request_params(attribs, json_root: json_root).reverse_merge credentials: api_creds
      parsed, _ = request(:post, url+'/verify', params)
      load(parsed)
      errors.empty? ? self : false
    end

  end
end
