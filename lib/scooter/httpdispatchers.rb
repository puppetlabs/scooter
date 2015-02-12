%w( consoledispatcher ).each do |lib|
  require "scooter/httpdispatchers/#{lib}"
end

module Scooter
  # This module is just the housing for the single dispatcher we have right now,
  # ConsoleDispatcher, but should eventually include other dispatchers for other
  # services that talk over http, such as the Puppet Server and PuppetDB.
  module HttpDispatchers
  end
end

