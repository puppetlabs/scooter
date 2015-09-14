module Scooter
  module HttpDispatchers
    module CodeManager
      # Methods here are generally representative of endpoints
      module V1

        def deploys(environments_payload_hash, token)
          end_point = '/code-manager/v1/deploys'
          end_point << "?token=#{token}"if token
          @connection.url_prefix.port = 8170
          @connection.post(end_point)do |req|
            req.body = environments_payload_hash
          end
        end

      end
    end
  end
end
