module SSLEnforcer
  class Enforce
    def initialize(app, options = {})
      @options              = { :subdomain => [] }.merge(options)
      @app                  = app
      @subdomains           = @options[:subdomain] || []
      @subdomain_exceptions = @options[:subdomain_exceptions] || []
    end

    def call(env)
      # if the domain is already using SSL don't do anything
      if url_is_ok?(env)
        @app.call(env)
      else
        # if the domain is NOT currently using SSL then we need to redirect the request
        req     = Rack::Request.new(env)
        headers = { "Location" => req.url.gsub(/^http:/, "https:") }

        [301, headers, []]
      end
    end

    private # -----------------------------------------------

    def url_is_ok?(env)
      tld       = get_top_level_domain(env["SERVER_NAME"])
      subdomain = get_subdomain(env["SERVER_NAME"], tld)

      # Hack to deal with heroku redirect issues.
      # http://rack.lighthouseapp.com/projects/22435/tickets/101
      scheme    = "https" if env["SERVER_PORT"] == "443"
      scheme    = env["HTTP_X_FORWARDED_PROTO"] if env["HTTP_X_FORWARDED_PROTO"]

      # If the subdomain is in the list of HTTPS enforced subs, check for HTTPS
      # otherwise, return true
      if @subdomains.index(subdomain).nil?
        return true
      else
        return scheme == "https"
      end
    end

    # return the subdomain regardless of how many levels deep it is
    def get_subdomain(server_name, tld)
      return server_name.gsub /\.?#{tld}$/, ""
    end

    # We will break the server URL into separate parts, reverse them and then
    # reconstruct the TLD (Top Level Domain) from there.  This should allow
    # for support of domains that extend beyond a third level
    # (i.e. - secure.my.domain.com)
    def get_top_level_domain(server_name)
      domain_parts = server_name.split(".").reverse
      return [domain_parts.second, domain_parts.first].join(".")
    end
  end
end