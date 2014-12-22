# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'scooter/version'

Gem::Specification.new do |spec|
  spec.name          = "scooter"
  spec.version       = Scooter::VERSION
  spec.authors       = ["Puppetlabs"]
  spec.email         = ["qa@puppetlabs.com"]
  spec.summary       = %q{Puppetlabs testing tool}
  spec.description   = %q{Puppetlabs testing tool coupled with Beaker}
  spec.homepage      = "https://github.com/puppetlabs/scooter"
  spec.license       = "Apache2"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  #Development dependencies
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "pry", '~> 0.9.12.6'

  #Documentation dependencies
  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'markdown'

  #Run time dependencies
  spec.add_runtime_dependency 'json'
  spec.add_runtime_dependency 'httparty'
  spec.add_runtime_dependency 'net-ldap'
  spec.add_runtime_dependency 'beaker'
  spec.add_runtime_dependency 'faraday'
  spec.add_runtime_dependency 'faraday_middleware'
  spec.add_runtime_dependency 'faraday-cookie_jar'
  spec.add_runtime_dependency 'nokogiri'
end
