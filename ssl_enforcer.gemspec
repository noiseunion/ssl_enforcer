# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ssl_enforcer/version'

Gem::Specification.new do |gem|
  gem.name          = "ssl_enforcer"
  gem.version       = SSLEnforcer::VERSION
  gem.authors       = ["JD Hendrickson"]
  gem.email         = ["jd@digitalopera.com"]
  gem.description   = "Simple Rack middleware for forcing SSL on specific subdomains of an application."
  gem.summary       = "Simple Rack middleware for forcing SSL on specific subdomains of an application."
  gem.homepage      = "https://github.com/digitalopera/ssl_enforcer/"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
