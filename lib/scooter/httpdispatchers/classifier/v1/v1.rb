module Scooter
  module HttpDispatchers
    module Classifier
      # Methods here are generally representative of endpoints, and depending
      # on the method, return either a Faraday response object or some sort of
      # instance of the object created/modified.
      module V1


        include Scooter::Utilities
        Rootuuid = '00000000-0000-4000-8000-000000000000'

        def create_node_group(options={})
          # name, classes, parent are the only required keys
          name        = options['name']    || RandomString.generate
          classes     = options['classes'] || {}
          parent      = options['parent']  || Rootuuid
          rule        = options['rule']
          id          = options['id']
          environment = options['environment']
          variables   = options['variables']
          description = options['description']

          hash = { "name"    => name,
                   "parent"  => parent,
                   "classes" => classes }

          if rule
            hash['rule'] = rule
          end
          if environment
            hash['environment'] = environment
          end
          if variables
            hash['variables'] = variables
          end
          if description
            hash['description'] = description
          end

          set_classifier_path
          if id
            @connection.put("v1/groups/#{id}") do |request|
              request.body = hash
            end
          else
            @connection.post('v1/groups') do |request|
              request.body = hash
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

      end
    end
  end
end