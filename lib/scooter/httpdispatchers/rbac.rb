%w( v1 ).each do |lib|
  require "scooter/httpdispatchers/rbac/v1/#{lib}"
end

module Scooter
  module HttpDispatchers
    # Methods added here are not representative of endpoints, but are more
    # generalized to be helper methods to to acquire data, such as getting
    # the id of a user based on their login name. Be cautious about using
    # these methods if you are utilizing a dispatcher with credentials;
    # the user is not guaranteed to have privileges for all the methods
    # defined here, or the user may not be signed in. If you have a method
    # defined here that is using the connection object directly, you should
    # probably be using a method defined in the version module instead.
    module Rbac

      include Scooter::HttpDispatchers::Rbac::V1
      include Scooter::Utilities

      def set_rbac_path(connection=self.connection)
        set_url_prefix
        connection.url_prefix.path = '/rbac-api'
      end

      def generate_local_user(options = {})
        email = options['email'] || "#{RandomString.generate(8)}@example.com"
        display_name = options['display_name'] || RandomString.generate(8)
        login = options['login'] || RandomString.generate(16)
        role_ids = options['role_ids'] || []
        password = options['password'] || 'Puppet11'

        user_hash = { "email" => email,
                      "display_name" => display_name,
                      "login" => login,
                      "role_ids" => role_ids,
                      "password" => password }

        response = create_local_user(user_hash)
        return response if response.env.status != 200
        Scooter::HttpDispatchers::ConsoleDispatcher.new(@host,
                                                        login: login,
                                                        password: password)
      end

      def generate_role(options = {})
        permissions  = options['permissions'] || []
        user_ids     = options['user_ids'] || []
        group_ids    = options['group_ids'] || []
        display_name = options['display_name'] || RandomString.generate
        description  = options['description'] || RandomString.generate

        role_hash = { "permissions"  => permissions,
                      "user_ids"     => user_ids,
                      "group_ids"    => group_ids,
                      "display_name" => display_name,
                      "description"  => description }

        response = create_role(role_hash)
        return response if response.env.status != 200
        response.env.body
      end

      def add_user_to_role(console_dispatcher, role)
        user_id = get_user_id_of_console_dispatcher(console_dispatcher)
        role['user_ids'].push(user_id)
        replace_role(role)
      end

      def remove_user_from_role(console_dispatcher, role)
        user_id = get_user_id_of_console_dispatcher(console_dispatcher)
        role['user_ids'].delete(user_id)
        replace_role(role)
      end

      def get_user_id_of_console_dispatcher(console_dispatcher)
        return get_user_id_by_login_name('api_user') if console_dispatcher.credentials == nil
        get_user_id_by_login_name(console_dispatcher.credentials.login)
      end

      def get_current_user_id
        get_current_user_data['id']
      end

      def get_console_dispatcher_data(console_dispatcher)
        users = get_list_of_users
        users.each do |user|
          return user if user['login'] == console_dispatcher.credentials.login
        end
        nil #return nil if the console dispatcher is not found
      end

      def update_console_dispatcher(update_hash, console_dispatcher)
        user = get_console_dispatcher_data(console_dispatcher)
        user.merge!(update_hash)
        update_local_user(user)
      end

      def revoke_console_dispatcher(console_dispatcher)
        update_console_dispatcher({'is_revoked' => true}, console_dispatcher)
      end

      def get_user_id_by_login_name(name)
        users = get_list_of_users
        users.each do |user|
          return user['id'] if user['login'] == name
        end
        nil #return nil if name is not found
      end

      def delete_local_console_dispatcher(console_dispatcher)
        uuid = get_user_id_of_console_dispatcher(console_dispatcher)
        delete_local_user(uuid)
      end

      def get_group_data_by_name(name)
        groups = get_list_of_groups
        groups.each do |group|
          return group if name == group['login']
        end
        nil #return nil if name is not found
      end

      def get_group_id(group_name)
        groups = get_list_of_groups
        groups.each do |group|
          return group['id'] if group_name == group['display_name']
        end
        nil #return nil if group_name not found
      end

      def get_role_by_name(role_name)
        roles = get_list_of_roles
        roles.each do |role|
          return role if role['display_name'] == role_name
        end
        nil # return nil if role_name not found
      end

      def get_role_id(role_name)
        roles = get_list_of_roles
        roles.each do |role|
          return role['id'] if role['display_name'] == role_name
        end
        nil #return nil if role_name not found
      end

      def reset_console_dispatcher_password(console_dispatcher, password)
        token = get_password_reset_token_for_console_dispatcher(console_dispatcher)
        reset_local_user_password(token, password)
        console_dispatcher.credentials.password = password
      end

      def reset_console_dispatcher_password_to_default(console_dispatcher)
        token = get_password_reset_token_for_console_dispatcher(console_dispatcher)
        reset_local_user_password(token, 'Puppet11')
        console_dispatcher.credentials.password = 'Puppet11'
      end

      def get_password_reset_token_for_console_dispatcher(console_dispatcher)
        uuid = get_user_id_of_console_dispatcher(console_dispatcher)
        create_password_reset_token(uuid)
      end

      def acquire_token_with_credentials(lifetime=nil)
        @token = acquire_token(credentials.login, credentials.password, lifetime)
      end
    end
  end
end
