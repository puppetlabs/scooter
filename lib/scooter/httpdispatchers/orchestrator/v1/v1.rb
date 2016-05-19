module Scooter
  module HttpDispatchers
    module Orchestrator
      # Methods here are generally representative of endpoints
      module V1

        def get_last_jobs(n_jobs)
          @connection.get("/v1/jobs") do |req|
            req.body = {:limit => n_jobs} if n_jobs
          end
        end

        def get_job(job_id)
          @connection.get("/v1/jobs/#{job_id}")
        end

        def get_nodes(job_id)
          @connection.get("/v1/jobs/#{job_id}/nodes")
        end

        def get_report(job_id)
          @connection.get("/v1/jobs/#{job_id}/report")
        end

        def get_events(job_id)
          @connection.get("/v1/jobs/#{job_id}/events")
        end
      end
    end
  end
end
