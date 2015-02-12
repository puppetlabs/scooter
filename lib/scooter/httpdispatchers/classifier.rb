%w( v1 ).each do |lib|
  require "scooter/httpdispatchers/classifier/v1/#{lib}"
end
module Scooter
  module HttpDispatchers
    # Methods added here are not representative of endpoints, but are more
    # generalized to be helper methods to to acquire data, such as getting
    # the uuid of a node group based on the name. Be cautious about using
    # these methods if you are utilizing a dispatcher with credentials;
    # the user is not guaranteed to have privileges for all the methods
    # defined here, or the user may not be signed in. If you have a method
    # defined here that is using the connection object directly, you should
    # probably be using a method defined in the version module instead.
    module Classifier

      include Scooter::HttpDispatchers::Classifier::V1

    end
  end
end