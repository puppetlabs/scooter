module Scooter
  module HttpDispatchers
    module CodeManager
      # Methods here are generally representative of endpoints
      #
      # Currently there is no httpdispatcher built for the CodeManager module
      # it is necessary to create one and extend this module onto it
      #
      # Example:
      # api = Scooter::HttpDispatchers::HttpDispatcher.new(master)
      # api.extend(Scooter::HttpDispatchers::CodeManager::V1)
      # api.deploy_environments(['environment_one', 'environment_two'])
      module V1

        def deploy_environments(environments_array)
          @connection.url_prefix.port = 8141
          @connection.post('/code-manager/v1/deploys') do |req|
            req.body = {:environments => environments_array}
          end
        end

        def deploy_all_environments
          @connection.url_prefix.port = 8141
          @connection.post('/code-manager/v1/deploys') do |req|
            req.body = {"all" => true}
          end
        end
      end
    end
  end
end
