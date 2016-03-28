module Scooter
  module HttpDispatchers
    class PuppetdbDispatcher < HttpDispatcher
      # Methods here are generally representative of endpoints, and depending
      # on the method, return either a Faraday response object or some sort of
      # instance of the object created/modified.
      module V1
        def query_nodes(query=nil)
          set_puppetdb_path
          @connection.post('query/v4/nodes') do |request|
            unless query.nil?
              request.params['query'] = query
            end
          end
        end
      end
    end
  end
end
