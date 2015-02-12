%w( directory_service ).each do |lib|
  require "scooter/httpdispatchers/rbac/v1/#{lib}"
end
module Scooter
  module HttpDispatchers
    module Rbac
      # Methods here are generally representative of endpoints, and depending
      # on the method, return either a Faraday response object or some sort of
      # instance of the object created/modified.
      module V1


        include Scooter::Utilities
        include Scooter::HttpDispatchers::Rbac::V1::DirectoryService

        def create_local_user(options = {})
          email = options['email'] || "#{RandomString.generate(4)}@example.com"
          display_name = options['display_name'] || RandomString.generate(4)
          login = options['login'] || RandomString.generate(4)
          role_ids = options['role_ids'] || []
          password = options['password'] || 'Puppet11'

          user_hash = { "email" => email,
                        "display_name" => display_name,
                        "login" => login,
                        "role_ids" => role_ids,
                        "password" => password }

          set_rbac_path
          response = @connection.post 'v1/users' do |request|
            request.body = user_hash
          end

          return response if response.env.status != 200

          Scooter::HttpDispatchers::ConsoleDispatcher.new(@dashboard,
                                                          login: login,
                                                          password: password)
        end

        def update_local_user(update_hash)
          set_rbac_path
          @connection.put "v1/users/#{update_hash['id']}" do |request|
            request.body = update_hash
          end
        end

        def delete_local_user(user_id)
          set_rbac_path
          @connection.delete "v1/users/#{user_id}"
        end

        def get_single_user_data(uuid)
          set_rbac_path
          @connection.get("v1/users/#{uuid}").env.body
        end

        def get_current_user_data
          set_rbac_path
          @connection.get('v1/users/current').env.body
        end

        # The ParseJson middleware throws an exception because this returns
        # json headers while simply returning a token. In order to avoid this
        # middleware throwing an error, we have to replace the connection with
        # a temporary connection that doesn't use that particular middleware.
        def create_password_reset_token(uuid)
          old_connection = @connection
          @connection = create_default_connection_and_initialize
          @connection.builder.delete(FaradayMiddleware::ParseJson)
          signin if !is_certificate_dispatcher?
          set_rbac_path
          token = @connection.post("v1/users/#{uuid}/password/reset").env.body

          #replace the old connection
          @connection = old_connection
          token
        end

        def get_list_of_users
          set_rbac_path
          @connection.get('v1/users').env.body
        end

        def get_list_of_groups
          set_rbac_path
          @connection.get('v1/groups').env.body
        end

        def get_list_of_roles
          set_rbac_path
          @connection.get('v1/roles').env.body
        end

      end
    end
  end
end