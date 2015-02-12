%w( string_utilities beaker_utilities).each do |lib|
  require "scooter/utilities/#{lib}"
end

module Scooter
  module Utilities
    include StringUtilities
  end
end