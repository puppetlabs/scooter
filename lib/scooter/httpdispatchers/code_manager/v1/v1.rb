module Scooter
  module HttpDispatchers
    module CodeManager
      # Methods here are generally representative of endpoints
      module V1

        def deploys(environments_payload_hash)
          @connection.url_prefix.port = 8170
          @connection.post('/code-manager/v1/deploys') do |req|
            req.body = environments_payload_hash
          end
        end

      end
    end
  end
end
