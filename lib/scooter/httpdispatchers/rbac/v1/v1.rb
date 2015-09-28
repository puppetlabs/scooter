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

        include Scooter::HttpDispatchers::Rbac::V1::DirectoryService

        def create_local_user(options)
          set_rbac_path
          @connection.post 'v1/users' do |request|
            request.body = options
          end
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
        # middleware throwing an error, we catch the exception and parse the
        # ParsingError object for a token in the error message.
        def create_password_reset_token(uuid)
          set_rbac_path
          begin
          token = @connection.post("v1/users/#{uuid}/password/reset").env.body
          rescue Faraday::ParsingError => error
            # Use a regex to parse the token from the ParsingError object
            regex = /\'(.+)\'/
            token = regex.match(error.message)[1]
          end
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

        def import_ldap_group(group_name, role_ids=[])
          set_rbac_path
          @connection.post('v1/groups') do |request|
            request.body = {'login' => group_name,
                            'role_ids' => role_ids}
          end
        end

        def get_list_of_roles
          set_rbac_path
          @connection.get('v1/roles').env.body
        end

        def create_role(options)
          set_rbac_path
          @connection.post('v1/roles') do |request|
            request.body = options
          end
        end

        def replace_role(role)
          set_rbac_path
          @connection.put("v1/roles/#{role['id']}") do |request|
            request.body = role
          end
        end

        def acquire_token(login, password, lifetime=nil)
          set_rbac_path
          response = @connection.post "v1/auth/token" do |request|
            creds= {}
            creds[:login] = login
            creds[:password] = password
            creds[:lifetime] = lifetime if lifetime
            request.body = creds
          end
          response.env.body['token']
        end

      end
    end
  end
end
