%w( v1 ).each do |lib|
  require "scooter/httpdispatchers/orchestrator/v1/#{lib}"
end

module Scooter
  module HttpDispatchers
    class OrchestratorDispatcher < HttpDispatcher

      include Scooter::HttpDispatchers::Orchestrator::V1

      def initialize(host)
        super(host)
        @connection.url_prefix.path = '/orchestrator'
        @connection.url_prefix.port = 8143
      end

      # @return [Faraday::Response] response object from Faraday http client
      def list_jobs(n_jobs=nil)
        get_last_jobs(n_jobs)
      end

      # @return [Faraday::Response] response object from Faraday http client
      def list_job_details(job_id)
        get_job(job_id)
      end

      # @return [Faraday::Response] response object from Faraday http client
      def list_nodes_associated_with_job(job_id)
        get_nodes(job_id)
      end

      # @return [Faraday::Response] response object from Faraday http client
      def get_job_report(job_id)
        get_report(job_id)
      end

      # @return [Faraday::Response] response object from Faraday http client
      def get_job_events(job_id)
        get_events(job_id)
      end

      # @return [Faraday::Response] response object from Faraday http client
      def environment(environment)
        get_environment(environment)
      end

      # @return [Faraday::Response] response object from Faraday http client
      def list_applications(environment)
        get_applications_in_environment(environment)
      end

      # @return [Faraday::Response] response object from Faraday http client
      def list_app_instances(environment)
        get_instances_in_environment(environment)
      end

      # @return [Faraday::Response] response object from Faraday http client
      def deploy_environment(environment, opts={})
        payload = opts
        payload['environment'] = environment
        post_deploy(payload)
      end

      # @return [Faraday::Response] response object from Faraday http client
      def stop_job(job_id)
        post_stop({'job' => "/jobs/#{job_id}"})
      end

      # @return [Faraday::Response] response object from Faraday http client
      def plan_job(environment, opts={})
        payload = opts
        payload['environment'] = environment
        post_plan(payload)
      end

      # @return [Faraday::Response] response object from Faraday http client
      def nodes_connected_to_broker(node_list)
        payload = {'nodes' => node_list}
        post_inventory(payload)
      end

      # @return [Faraday::Response] response object from Faraday http client
      def create_dumpling(dumpling)
        post_dumpling(dumpling)
      end
    end
  end
end
