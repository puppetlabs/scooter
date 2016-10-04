module Scooter
  module HttpDispatchers
    module Orchestrator
      # Methods here are generally representative of endpoints
      module V1

        #jobs endpoints
        def get_last_jobs(n_jobs)
          @connection.get("v1/jobs") do |req|
            req.body = {:limit => n_jobs} if n_jobs
          end
        end

        def get_job(job_id)
          @connection.get("v1/jobs/#{job_id}")
        end

        def get_nodes(job_id)
          @connection.get("v1/jobs/#{job_id}/nodes")
        end

        def get_report(job_id)
          @connection.get("v1/jobs/#{job_id}/report")
        end

        def get_events(job_id)
          @connection.get("v1/jobs/#{job_id}/events")
        end

        #environments endpoints
        def get_environment(environment)
          @connection.get("v1/environments/#{environment}")
        end

        def get_applications_in_environment(environment)
          @connection.get("v1/environments/#{environment}/applications")
        end

        def get_instances_in_environment(environment)
          @connection.get("v1/environments/#{environment}/instances")
        end

        #command endpoints
        def post_deploy(payload)
          @connection.post("v1/command/deploy") do |req|
            req.body = payload
          end
        end

        def post_stop(payload)
          @connection.post("v1/command/stop") do |req|
            req.body = payload
          end
        end

        def post_plan(payload)
          @connection.post("v1/command/plan") do |req|
            req.body = payload
          end
        end

        #inventory endpoints
        def get_inventory(node=nil)
          url = "v1/inventory"
          url << "/#{node}" if node
          @connection.get(url)
        end

        def post_inventory(payload)
          @connection.post('v1/inventory') do |req|
            req.body = payload
          end
        end
      end
    end
  end
end
