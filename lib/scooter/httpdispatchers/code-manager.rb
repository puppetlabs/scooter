%w( v1 ).each do |lib|
  require "scooter/httpdispatchers/code-manager/v1/#{lib}"
end

module Scooter
  module HttpDispatchers
    # Currently there is no httpdispatcher built for the CodeManager module
    # it is necessary to create one and extend this module onto it
    #
    # Example:
    # api = Scooter::HttpDispatchers::HttpDispatcher.new(master)
    # api.extend(Scooter::HttpDispatchers::CodeManager)
    # api.deploy_environments(['environment_one', 'environment_two'])
    module CodeManager

      include Scooter::HttpDispatchers::CodeManager::V1

      def deploy_environments(environment_array)
        deploys({:environments => environment_array})
      end

      def deploy_all_environments
        deploys({"all" => true})
      end
    end
  end
end