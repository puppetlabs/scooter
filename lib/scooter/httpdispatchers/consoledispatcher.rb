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
    #  include "Scooter::HttpDispatcher"
    #
    #  certificate_dispatcher = ConsoleDispatcher.new(dashboard)
    #
    #  # creates a new user and returns a new ConsoleDispatcher
    #  new_user = api.create_local_user('login' => 'Chuck')
    #
    #  # because the new_user has credentials, it can signin
    #  new_user.signin
    #
    #  # this will trigger the middleware error handler, because you cannot
    #  # create two users with the same login
    #  certificate_dispatcher.create_local_user('login' => 'Chuck')
    #
    #  # this will return Chuck's data
    #  certificate_dispatcher.get_console_dispatcher_data(new_user)
    #
    #  # this will trigger a middleware error handler, because Chuck has no
    #  # privilege to create new users
    #  new_user.create_local_user
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
      attr_accessor :credentials, :token, :send_auth_token_as_query_param
      Credentials = Struct.new(:login, :password)

      # This class is designed to interact with any of the pe-console-services:
      # RBAC, Node Classifier, and the Activity Service. The most common use
      # case will be for tests executed with beaker, for which you will want
      # to pass in the dashboard for initialization. The other parameter that
      # you can pass in optionally is credentials. Passing in credentials is
      # essential for building the correct routes if you are using RBAC users,
      # local users, or the default admin account. If no credentials are passed
      # in, the dispatcher defaults to using certificates to connect to the
      # API's directly.
      #
      # If you are using this class outside of beaker, you can initialize an
      # object without any parameters and supply your own dashboard as a String,
      # credentials, Faraday connection object, and ssl parameters. Note that
      # this is largely untested. Use outside of a Beaker test run at your own
      # risk.
      #
      # @param credentials(Hash optional) Provide credentials if you wish to
      #   communicate through the UI proxy. If no credentials are provided, then
      #   it is assumed the dispatching object will send traffic directly to the
      #   Services.
      def initialize(host, credentials=nil)
        @credentials = Credentials.new(credentials[:login],
                                       credentials[:password]) if credentials
        super(host)
      end

      # This slightly overrides the original method to add the middleware to
      # to add rbac tokens when available.
      def create_default_connection
        connection = super
        connection.builder.insert(0, Faraday::RbacAuthToken, self)
        connection
      end

      def set_url_prefix(connection=self.connection)
        if is_certificate_dispatcher? || has_token?
          connection.url_prefix.port = 4433
        else
          connection.url_prefix.port = 443
        end
        super(connection)
      end

      # This is overridden from the parent class; in the case of
      # ConsoleDispatcher objects, there are often cases where the Dispatcher is
      # not a certificate dispatcher, but representing an LDAP or local user.
      def acquire_ssl_components(host=self.host)
        if is_certificate_dispatcher?
          super(host)
        else
          if !host.is_a?(Unix::Host)
            raise 'Can only acquire SSL certs if the host is a Unix::Host'
          end
         acquire_ca_cert(host)
        end
      end

      def is_certificate_dispatcher?
        true unless @credentials
      end

      def has_token?
        true if @token
      end

      def signin(login=self.credentials.login, password=self.credentials.password)
        response = @connection.post "/auth/login" do |request|
          request.headers['Content-Type'] = 'application/x-www-form-urlencoded; charset=UTF-8'
          request.body = "username=#{login}&password=#{CGI.escape(password)}"
        end

        #return the response if the status code was not 200
        return response if response.status != 200

        # try to be helpful and acquire the xcsrf; catch any error that occurs
        # in the acquire_xcsrf method
        begin
          acquire_xcsrf
        rescue
          # do nothing in the rescue
        end
      end

      def acquire_xcsrf
        # This simply makes a call to the base_uri and extracts out an
        # anti-forgery-token and adds that token to the headers for the
        #connection object
        @connection.url_prefix.path = ''
        response_body = @connection.get.env.body
        parsed_body = Nokogiri::HTML(response_body)
        token = parsed_body.css("meta[name='__anti-forgery-token']")[0].attributes['content'].value
        @connection.headers['X-CSRF-Token'] = token
      end

      def reset_local_user_password(token, new_password)
        @connection.post "https://#{host}/auth/reset" do |request|
          request.headers['Content-Type'] = 'application/x-www-form-urlencoded; charset=UTF-8'
          request.body = "password=#{new_password}&token=#{token}"
        end
      end

    end
  end
end
