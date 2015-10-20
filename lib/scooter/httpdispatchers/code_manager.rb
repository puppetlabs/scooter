%w( v1 ).each do |lib|
  require "scooter/httpdispatchers/code_manager/v1/#{lib}"
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

      def deploy_environments(environment_array, wait=true)
        raise ArgumentError.new('wait must be TrueClass or FalseClass') unless !!wait == wait
        payload = {:environments => environment_array, 'wait' => wait}
        deploys(payload)
      end

      def deploy_all_environments(wait=true)
        raise ArgumentError.new('wait must be TrueClass or FalseClass') unless !!wait == wait
        payload = {'deploy-all' => true, 'wait' => wait}
        deploys(payload)
      end
    end
  end
end