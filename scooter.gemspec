# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'scooter/version'

Gem::Specification.new do |spec|
  spec.name          = "scooter"
  spec.version       = Scooter::Version::STRING
  spec.authors       = ["Puppetlabs"]
  spec.email         = ["qa@puppetlabs.com"]
  spec.summary       = %q{Puppetlabs testing tool}
  spec.description   = %q{Puppetlabs testing tool coupled with Beaker}
  spec.homepage      = "https://github.com/puppetlabs/scooter"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  #Development dependencies
  spec.add_development_dependency 'bundler', '~> 2'
  spec.add_development_dependency 'pry', '~> 0.10'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '>= 3.0.0'
  spec.add_development_dependency 'beaker-abs'
  spec.add_development_dependency 'webmock', '~> 3.13'

  #Documentation dependencies
  spec.add_development_dependency 'yard', '~> 0.9.11'
  spec.add_development_dependency 'markdown', '~> 0'
  spec.add_development_dependency 'activesupport', '4.2.8'

  #Run time dependencies
  spec.add_runtime_dependency 'beaker'
  spec.add_runtime_dependency 'json'
  spec.add_runtime_dependency 'test-unit'
  spec.add_runtime_dependency 'net-ldap', '~> 0.16'
  spec.add_runtime_dependency 'faraday'
  spec.add_runtime_dependency 'faraday_middleware', '~> 1.2'
  spec.add_runtime_dependency 'faraday-cookie_jar', '>= 0.0.7'
end
