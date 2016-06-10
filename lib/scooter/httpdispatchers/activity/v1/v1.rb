module Scooter
  module HttpDispatchers
    module Activity
      # Methods here are generally representative of endpoints, and depending
      # on the method, return either a Faraday response object or some sort of
      # instance of the object created/modified.
      module V1
        # Gets events from classifier
        #
        # @param [Hash] filters query strings to filter the activity events:
        # @option filters [String] :subject_type [optional; required only when subject_id is provided]
        # @option filters [String] :subject_id [optional; comma-separated list of subject_ids]
        # @option filters [String] :object_type [optional; required only when object_id is provided]
        # @option filters [String] :object_id [optional; comma-separated list of object_ids]
        # @option filters [String] :offset [optional; skip n event commits]
        # @option filters [String] :limit [optional; return no more than n event commits; defaults to 1000]
        # @return [Object] The events queried
        def get_classifier_events(filters = {})
          set_activity_path
          @connection.get 'v1/events' do |request|
            request.params['service_id'] = 'classifier'
            filters.each { |param, value|
              request.params[param] = value
            }
          end
        end

        # Gets events from rbac
        #
        # @param [Hash] filters query strings to filter the activity events:
        # @option filters [String] :subject_type [optional; required only when subject_id is provided]
        # @option filters [String] :subject_id [optional; comma-separated list of subject_ids]
        # @option filters [String] :object_type [optional; required only when object_id is provided]
        # @option filters [String] :object_id [optional; comma-separated list of object_ids]
        # @option filters [String] :offset [optional; skip n event commits]
        # @option filters [String] :limit [optional; return no more than n event commits; defaults to 1000]
        # @return [Object] The events queried
        def get_rbac_events(filters = {})
          set_activity_path
          @connection.get 'v1/events' do |request|
            request.params['service_id'] = 'rbac'
            filters.each { |param, value|
              request.params[param] = value
            }
          end
        end
      end
    end
  end
end
