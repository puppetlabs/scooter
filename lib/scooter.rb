require 'scooter/version'
require 'beaker'
require 'net/ldap'
require 'faraday'
require 'faraday_middleware'
require 'faraday-cookie_jar'
require 'forwardable'
require 'beaker-http/helpers/puppet_helpers'
require 'beaker-http/dsl/web_helpers'
require "beaker-http/http"
require 'beaker-http/middleware/response/faraday_beaker_logger'

module Scooter
  %w( utilities httpdispatchers ldap ).each do |lib|
    require "scooter/#{lib}"
  end
end
