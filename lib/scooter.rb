require 'scooter/version'
require 'beaker'
require 'net/ldap'
require 'beaker-http'
require 'faraday'
require 'faraday_middleware'
require 'faraday-cookie_jar'

module Scooter
  %w( utilities httpdispatchers ldap ).each do |lib|
    require "scooter/#{lib}"
  end
end
