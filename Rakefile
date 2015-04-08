require "bundler/gem_tasks"

require 'rspec/core/rake_task'

desc "Run spec tests"
RSpec::Core::RakeTask.new(:test) do |t|
  t.rspec_opts = ['--color']
  t.pattern = 'spec/'
end
