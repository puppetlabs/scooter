module Scooter
  module HttpDispatchers
    module Orchestrator
      # Methods here are generally representative of endpoints
      module V1

        def initialize(host)
          super(host)
          @version = 'v1'
        end

        #jobs endpoints
        def get_last_jobs(n_jobs)
          @connection.get("#{@version}/jobs") do |req|
            req.params['limit'] = n_jobs if n_jobs
          end
        end

        def get_job(job_id)
          @connection.get("#{@version}/jobs/#{job_id}")
        end

        def get_nodes(job_id)
          @connection.get("#{@version}/jobs/#{job_id}/nodes")
        end

        def get_report(job_id)
          @connection.get("#{@version}/jobs/#{job_id}/report")
        end

        def get_events(job_id)
          @connection.get("#{@version}/jobs/#{job_id}/events")
        end

        #environments endpoints
        def get_environments
          @connection.get("v1/environments")
        end

        def get_environment(environment)
          @connection.get("#{@version}/environments/#{environment}")
        end

        def get_applications_in_environment(environment)
          @connection.get("#{@version}/environments/#{environment}/applications")
        end

        def get_instances_in_environment(environment)
          @connection.get("#{@version}/environments/#{environment}/instances")
        end

        #command endpoints
        def post_deploy(payload)
          @connection.post("#{@version}/command/deploy") do |req|
            req.body = payload
          end
        end

        def post_stop(payload)
          @connection.post("#{@version}/command/stop") do |req|
            req.body = payload
          end
        end

        def post_plan(payload)
          @connection.post("#{@version}/command/plan") do |req|
            req.body = payload
          end
        end

        #inventory endpoints
        def get_inventory(node=nil)
          url = "#{@version}/inventory"
          url << "/#{node}" if node
          @connection.get(url)
        end

        def post_inventory(payload)
          @connection.post("#{@version}/inventory") do |req|
            req.body = payload
          end
        end

        #status endpoint
        def get_status
          @connection.get("#{@version}/status")
        end
      end
    end
  end
end
