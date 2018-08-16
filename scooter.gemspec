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
  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'pry', '~> 0.9.12'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '>= 3.0.0'
  spec.add_development_dependency 'beaker-abs', '~>0.3.0'

  #Documentation dependencies
  spec.add_development_dependency 'yard', '~> 0.9.11'
  spec.add_development_dependency 'markdown', '~> 0'
  spec.add_development_dependency 'activesupport', '4.2.6'

  #Run time dependencies
  spec.add_runtime_dependency 'beaker-http', '~> 0.1'
  spec.add_runtime_dependency 'json', '~> 1.8'
  spec.add_runtime_dependency 'test-unit'
  spec.add_runtime_dependency 'net-ldap', '~> 0.6', '>= 0.6.1', '<= 0.12.1'
  spec.add_runtime_dependency 'beaker', '>= 3.0.0'
  spec.add_runtime_dependency 'faraday', '~> 0.9', '>= 0.9.1'
  spec.add_runtime_dependency 'faraday_middleware', '~> 0.9'
  spec.add_runtime_dependency 'faraday-cookie_jar', '~> 0.0', '>= 0.0.6'
end
