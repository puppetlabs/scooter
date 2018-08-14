module Scooter
  module HttpDispatchers
    class PEBoltServerDispatcher < HttpDispatcher

      def initialize(host)
        super(host)
        @connection.url_prefix.port = 8144
      end

      # @return [Faraday::Response] response object from Faraday http client
      def ssh_run_task(task)
        @connection.post("ssh/run_task") do |req|
          req.body = task
        end
      end
    end
  end
end
