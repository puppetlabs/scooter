%w( rbac classifier).each do |lib|
  require "scooter/httpdispatchers/#{lib}"
end
require 'resolv'

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
    class ConsoleDispatcher

      include Scooter::HttpDispatchers::Rbac
      include Scooter::HttpDispatchers::Classifier
      attr_accessor :connection, :dashboard, :credentials, :ssl
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
      # @param dashboard [Unix::Host optional] the dashboard specified in your
      #   beaker config. If no dashboard is passed, then the initialization
      #   process is skipped and you must define the connection and dashboard
      #   manually.
      #
      # @param credentials(Hash optional) Provide credentials if you wish to
      #   communicate through the UI proxy. If no credentials are provided, then
      #   it is assumed the dispatching object will send traffic directly to the
      #   Services.
      def initialize(dashboard = nil, credentials=nil)
        @dashboard = dashboard if dashboard.is_a?(Unix::Host)
        @credentials = Credentials.new(credentials[:login],
                                       credentials[:password]) if credentials

        @connection = create_default_connection_and_initialize if @dashboard
      end

      def create_default_connection
        Faraday.new do |conn|
          conn.request :json

          # This logger will need to be configurable somehow..., maybe based on
          # beaker log-level?
          conn.response :follow_redirects
          conn.response :json, :content_type => /\bjson$/
          conn.response :raise_error
          conn.response :logger, nil, bodies: true

          conn.use :cookie_jar

          conn.adapter :net_http
        end
      end

      def create_default_connection_and_initialize
        connection = create_default_connection
        set_host_and_port(connection)
        acquire_ssl_components
        add_ssl_components_to_connection(connection)
        connection
      end


      # If you would like to run tests that expect 400 or even 500 responses,
      # apply this method to remove the <tt>:raise_error</tt> middleware.
      def remove_error_checking(connection=@connection)
        connection.builder.delete(Faraday::Response::RaiseError)
      end

      # See if we can reach the dashboard by hostname
      def is_resolvable(dashboard=@dashboard)
        begin
          Resolv.getaddress(@dashboard.hostname)
          true
        rescue Resolv::ResolvError
          false
        end
      end


      def set_host_and_port(connection=@connection)
        connection.url_prefix.scheme = 'https'
        connection.url_prefix.host = is_resolvable ? @dashboard.hostname : Scooter::Utilities::BeakerUtilities.get_public_ip(@dashboard)

        if is_certificate_dispatcher?
          connection.url_prefix.port = 4433
        else
          connection.url_prefix.port = 443
        end
      end

      def set_classifier_path(connection=@connection)
        if is_certificate_dispatcher?
          connection.url_prefix.path = '/classifier-api'
        else
          connection.url_prefix.path = '/api/classifier/service/'
        end
      end

      def set_rbac_path(connection=@connection)
        if is_certificate_dispatcher?
          connection.url_prefix.path = '/rbac-api'
        else
          connection.url_prefix.path = '/api/rbac/service/'
        end
      end

      def set_activity_service_path(connection=@connection)
        if is_certificate_dispatcher?
          connection.url_prefix.path = '/activity-api'
        else
          connection.url_prefix.path = '/rbac/activity-api'
        end
      end

      def acquire_ssl_components
        if !@dashboard.is_a?(Unix::Host)
          raise 'Can only acquire SSL certs if the dashboard is a Unix::Host'
        end
        @ssl = {}

        @ssl['ca_file'] = Scooter::Utilities::BeakerUtilities.pe_ca_cert_file(@dashboard)
        if is_certificate_dispatcher?
          client_key = Scooter::Utilities::BeakerUtilities.pe_private_key(@dashboard)
          client_cert = Scooter::Utilities::BeakerUtilities.pe_hostcert(@dashboard)

          @ssl['client_key']  = OpenSSL::PKey.read(client_key)
          @ssl['client_cert'] = OpenSSL::X509::Certificate.new(client_cert)
        end
      end

      def add_ssl_components_to_connection(connection=@connection)
        @ssl.each do |k, v|
          connection.ssl[k] = v
        end

        if connection.url_prefix.host == Scooter::Utilities::BeakerUtilities.get_public_ip(@dashboard) && connection.ssl['verify'] == nil
          # Becuase we are connecting to the dashboard by IP address, SSL verification
          # against the CA will fail. Disable verifying against it for now until a better
          # fix can be found.
          connection.ssl['verify'] = false
        end
      end

      # Run this method if you have replaced the connection with a different
      # Faraday connection; it will just set the prefix_url and add the ssl
      # components already stored. This method is used primarily when you have
      # not passed in a dashboard from beaker and are acquiring ssl credentials
      # through separate means; it skips the <tt>acquire_ssl_components</tt>
      # and assumes that you acquired an ssl client_key and client_cert through
      # separate means.
      def reinitialize_connection(connection=@connection)
        set_host_and_port(connection)
        add_ssl_components_to_connection(connection)
      end

      def is_certificate_dispatcher?
        true unless @credentials
      end

      def signin(login=@credentials.login, password=@credentials.password)
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
        response_body = @connection.get.env.body
        parsed_body = Nokogiri::HTML(response_body)
        token = parsed_body.css("meta[name='__anti-forgery-token']")[0].attributes['content'].value
        @connection.headers['X-CSRF-Token'] = token
      end

      def reset_local_user_password(token, new_password)
        @connection.post "https://#{dashboard}/auth/reset" do |request|
          request.headers['Content-Type'] = 'application/x-www-form-urlencoded; charset=UTF-8'
          request.body = "password=#{new_password}&token=#{token}"
      end

      end
    end
  end
end
