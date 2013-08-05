require "rack"
require "rack/request"

class SSLEnforcer::Enforcer
  def initialize(app, options = {})
    @options    = { :only => [] }.merge(options)
    @app        = app
    @only       = @options[:only] || []
    @exceptions = @options[:except] || []

    ## Convert @only and @exception values to symbols
    @exceptions.map!{ |sd| sd.downcase.to_sym }
    @only.map!{ |sd| sd.downcase.to_sym }
  end

  def call(env)
    # if the domain is already using SSL don't do anything
    if url_is_ok?(env)
      @app.call(env)
    else
      # if the domain is NOT currently using SSL then we need to redirect the request
      req     = Rack::Request.new(env)
      headers = { "Location" => req.url.gsub(/^http:/, "https:"), "Content-Type"=>"text/plain" }

      [301, headers, []]
    end
  end

  private # -----------------------------------------------

  def url_is_ok?(env)
    tld       = get_top_level_domain(env["SERVER_NAME"])
    subdomain = get_subdomain(env["SERVER_NAME"], tld).downcase.to_sym

    # Hack to deal with heroku redirect issues.
    # http://rack.lighthouseapp.com/projects/22435/tickets/101
    scheme    = (env["SERVER_PORT"] == "443") ? :https : :http
    scheme    = env["HTTP_X_FORWARDED_PROTO"] if env["HTTP_X_FORWARDED_PROTO"]

    # If the "only" and or "exceptions" options have not been passed, then
    # we want to force SSL on ALL subdomains
    return false if @only.empty? && @exceptions.empty?

    ## Return true if the subdomain is in in the "except" list
    return true if @exceptions.include?(subdomain)

    ## Return the current scheme test restuls if the
    ## subdomain is in the "only" list
    return scheme == :https if @only.include?(subdomain)

    ## If the subdomain is not found in either @exceptions || @only
    ## we must first check to see if the "only" option was passed.
    ## If so, then we will return true and not change the request.
    ## If the option was not passed, then we must assume to change all
    ## subdomains NOT responded to by @exceptions
    if @only.empty?
      return scheme == :https
    else
      return true
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