%w( v1 ).each do |lib|
  require "scooter/httpdispatchers/orchestrator/v1/#{lib}"
end

module Scooter
  module HttpDispatchers
    # TODO update for Orchestrator ???
    # Currently there is no httpdispatcher built for the Orchestrator module
    # it is necessary to create one and extend this module onto it
    #
    # Example:
    # orchestrator = Scooter::HttpDispatchers::HttpDispatcher.new(master)
    # orchestrator.extend(Scooter::HttpDispatchers::Orchestrator)
    # orchestrator.get_job_details('this is my job id')
    class OrchestratorDispatcher < HttpDispatcher

      include Scooter::HttpDispatchers::Orchestrator::V1

      def initialize(host)
        super(host)
        @connection.url_prefix.path = '/orchestator'
        @connection.url_prefix.port = 8143
      end

      def list_jobs(n_jobs=nil)
        get_last_jobs(n_jobs)
      end

      def list_job_details(job_id)
        get_job(job_id)
      end

      def list_nodes_associated_with_job(job_id)
        get_nodes(job_id)
      end

      def get_job_report(job_id)
        get_report(job_id)
      end

      def get_job_events(job_id)
        get_events(job_id)
      end
    end
  end
end
