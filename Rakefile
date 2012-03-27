# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name = "ssl_enforcer"
  gem.homepage = "http://github.com/noiseunion/ssl_enforcer"
  gem.license = "MIT"
  gem.summary = "Force SSL for specific subdomains of your application"
  gem.description = "Simple Rack middleware for forcing SSL on specific subdomains of an application."
  gem.email = "jd@digitalopera.com"
  gem.authors = ["JD Hendrickson"]
end
Jeweler::RubygemsDotOrgTasks.new