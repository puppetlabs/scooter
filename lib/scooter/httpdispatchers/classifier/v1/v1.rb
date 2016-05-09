require 'json'

module Scooter
  module HttpDispatchers
    module Classifier
      # Methods here are generally representative of endpoints, and depending
      # on the method, return either a Faraday response object or some sort of
      # instance of the object created/modified.
      module V1

        def create_node_group(options)
          set_classifier_path
          if options['id']
            @connection.put("v1/groups/#{options['id']}") do |request|
              request.body = options
            end
          else
            @connection.post('v1/groups') do |request|
              request.body = options
            end
          end
        end

        def get_list_of_node_groups
          set_classifier_path
          @connection.get('v1/groups').env.body
        end

        def get_node_group(uuid)
          set_classifier_path
          @connection.get("v1/groups/#{uuid}").env.body
        end

        def get_last_update
          set_classifier_path
          result = @connection.get('v1/last-class-update').env.body
          JSON.parse(result)['last_update']
        end

        def delete_node_group(uuid)
          set_classifier_path
          @connection.delete("v1/groups/#{uuid}")
        end

        def replace_node_group(node_group_id, node_group_model)
          set_classifier_path
          @connection.put("v1/groups/#{node_group_id}") do |request|
            request.body = node_group_model
          end
        end

        def update_node_group(node_group_id, update_hash)
          set_classifier_path
          @connection.post("v1/groups/#{node_group_id}") do |request|
            request.body = update_hash
          end
        end

        def import_hierarchy(hierarchy)
          set_classifier_path
          @connection.post('v1/import-hierarchy') do |request|
            request.body = hierarchy
          end
        end

        def update_classes(environment=nil, wait_for_update=false)
          set_classifier_path
          last_update = get_last_update

          @connection.post('v1/update-classes') do |request|
            unless environment.nil?
              request.params['environment'] = environment
            end
          end

          if wait_for_update
            while last_update == get_last_update
              sleep 3
            end
          end
        end

        def pin_nodes(node_group_id, nodes)
          set_classifier_path
          @connection.post("v1/groups/#{node_group_id}/pin") do |request|
            request.body = nodes
          end
        end

        def unpin_nodes(node_group_id, nodes)
          set_classifier_path
          @connection.post("v1/groups/#{node_group_id}/unpin") do |request|
            request.body = nodes
          end
        end
      end
    end
  end
end
