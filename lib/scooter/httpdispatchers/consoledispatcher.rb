%w( rbac classifier activity).each do |lib|
  require "scooter/httpdispatchers/#{lib}"
end

module Scooter

  module HttpDispatchers

    # == Quick-start guide
    # === example creating a ConsoleDispatcher with certificates and credentials
    #
    #  require 'scooter'
    #
    #  include Scooter::HttpDispatcher
    #
    #  console_dispatcher = ConsoleDispatcher.new(dashboard)
    #
    #  # creates a new user and returns a new ConsoleDispatcher
    #  new_user = console_dispatcher.generate_local_user('login' => 'Chuck')
    #
    #  # because the new_user has credentials, it can signin
    #  new_user.signin
    #
    #  # this will trigger the middleware error handler, because you cannot
    #  # create two users with the same login
    #  console_dispatcher.create_local_user('login' => 'Chuck')
    #
    #  # this will return Chuck's data
    #  certificate_dispatcher.get_console_dispatcher_data(new_user)
    #
    #  # this will trigger a middleware error handler, because Chuck has no
    #  # privilege to create new users
    #  new_user.generate_local_user
    #
    #  # this will delete Chuck from RBAC
    #  certificate_dispatcher.delete_local_console_dispatcher(new_user)
    #
    #  # this method will now return nil because new_user is deleted
    #  certificate_dispatcher.get_console_dispatcher_data(new_guy)
    class ConsoleDispatcher < HttpDispatcher

      include Scooter::HttpDispatchers::Rbac
      include Scooter::HttpDispatchers::Classifier
      include Scooter::HttpDispatchers::Activity
      attr_accessor :credentials
      Credentials = Struct.new(:login, :password)

      # This class is designed to interact with any of the pe-console-services:
      # RBAC, Node Classifier, and the Activity Service. The most common use
      # case will be for tests executed with beaker, for which you will want
      # to pass in the dashboard for initialization. The other parameter that
      # you can pass in optionally is credentials, if you wish to get a web
      # session and use that to talk to various other parts of PE.
      #
      # If you are using this class outside of beaker, you can initialize an
      # object without any parameters and supply your own dashboard as a String,
      # credentials, Faraday connection object, and ssl parameters. Note that
      # this is largely untested. Use outside of a Beaker test run at your own
      # risk.
      #
      # @param credentials(Hash optional) Provide credentials if you wish to
      #   communicate through the UI proxy.
      def initialize(host, credentials=nil, log_level=Logger::DEBUG, log_body=true)
        @credentials = Credentials.new(credentials[:login],
                                       credentials[:password]) if credentials
        super(host, log_level, log_body)
      end

      def set_url_prefix(connection=self.connection)
        connection.url_prefix.port = 4433
        super(connection)
      end

      # This is overridden from the parent class; in the case of
      # ConsoleDispatcher objects, there are often cases where the Dispatcher is
      # not a certificate dispatcher, but representing an LDAP or local user. If
      # credentials are supplied during initialization, then this overrides the
      # parent class and only acquires a ca_cert.
      def acquire_ssl_components(host=self.host)
        if credentials == nil
          super(host)
        else
          if !host.is_a?(Unix::Host)
            raise 'Can only acquire SSL certs if the host is a Unix::Host'
          end
          acquire_ca_cert(host)
        end
      end

      def signin(login=self.credentials.login, password=self.credentials.password)
        response = @connection.post "/auth/login" do |request|
          request.headers['Content-Type'] = 'application/x-www-form-urlencoded; charset=UTF-8'
          request.body = "username=#{login}&password=#{CGI.escape(password)}"
          connection.port = 443
        end
        return response if response.status != 200
        # This just had to be a string...*sigh*
        header_array = response.headers['Set-Cookie'].split(';')
        pl_ssti = header_array.select{|s| s =~ /pl_ssti/}
        pl_ssti_value = pl_ssti[0].partition('pl_ssti=').last
        @connection.headers['Cookie'] = response.headers['Set-Cookie']
        @connection.headers['X-Authentication'] = pl_ssti_value
        # Reset the connection port, since we have to hardcode it to 443 signin
        set_url_prefix
      end

      def reset_local_user_password(token, new_password)
        @connection.post "https://#{host}/auth/reset" do |request|
          request.headers['Content-Type'] = 'application/x-www-form-urlencoded; charset=UTF-8'
          request.body = "password=#{new_password}&token=#{token}"
          connection.port = 443
        end
        set_url_prefix
      end

    end
  end
end
