require 'scooter/version'
require 'httparty'
require 'beaker'
require 'net/ldap'
require 'faraday'
require 'faraday_middleware'
require 'faraday-cookie_jar'
require 'nokogiri'

module Scooter
  %w( utilities httpdispatchers ldap ).each do |lib|
    require "scooter/#{lib}"
  end
end