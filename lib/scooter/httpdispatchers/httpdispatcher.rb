module Scooter
  module HttpDispatchers

    require 'scooter/httpdispatchers/code_manager'
    require 'scooter/middleware/rbac_auth_token'

    # <i>HttpDispatcher</i> is the base class to extend when constructing
    # service specific objects. It contains specific logic to extract out
    # certificates from Beaker hosts provided as the host argument.
    # You can directly instantiate from this class if you would like only this
    # low level functionality. Otherwise, the primary function of this class
    # is to allow more specific Dispatchers, such as the ConsoleDispatcher, to
    # extend it and write higher level functionality.
    class HttpDispatcher


      attr_accessor :connection, :host, :ssl, :token, :send_auth_token_as_query_param
      # The only required parameter for the HttpDispatcher is the host, which
      # could either be a beaker Unix::Host or a String. HttpDispatchers offer
      # support for automatically generating the required SSL components for the
      # Dispatcher if it is passed a Unix Host.
      #
      # If it is only passed a String, than it is up to the caller to correctly
      # configure the connection object to be configured correctly. Support for
      # Strings is experimental for now; it may be deprecated if there is no
      # feedback indicating that this functionality is being used.
      #
      # @param host(Unix::Host) The beaker host object you wish to communicate
      #   with.
      def initialize(host)
        @ssl = {}
        @host = host
        if @host.is_a?(Unix::Host)
          @connection = create_default_connection_with_beaker_host
        elsif @host.is_a?(String)
          @connection = create_default_connection
          set_url_prefix
        else
          raise "Argument host must be Unix::Host or String"
        end
      end

      def initialize_connection
        if @host.is_a?(Unix::Host)
          @connection = create_default_connection_with_beaker_host
        elsif @host.is_a?(String)
          @connection = create_default_connection
          set_url_prefix
          add_ssl_components_to_connection
        else
          raise "Argument host must be Unix::Host or String"
        end

      end
      def create_default_connection
        Faraday.new do |conn|
          conn.request :rbac_auth_token, self
          conn.request :json

          # This logger will need to be configurable somehow..., maybe based on
          # beaker log-level?
          conn.response :follow_redirects
          conn.response :raise_error
          conn.response :json, :content_type => /\bjson$/
          conn.response :logger, nil, bodies: true

          conn.use :cookie_jar

          conn.adapter :net_http
        end
      end

      def set_url_prefix(connection=self.connection)
        if host.is_a?(Unix::Host)
          connection.url_prefix.host = is_resolvable ? host.hostname : Scooter::Utilities::BeakerUtilities.get_public_ip(host)
        else
          connection.url_prefix.host = host
        end
      end

      def create_default_connection_with_beaker_host
        connection = create_default_connection
        set_url_prefix(connection)
        acquire_ssl_components if ssl.empty?
        add_ssl_components_to_connection(connection)
        connection
      end

      # See if we can reach the host by hostname
      def is_resolvable(host=self.host)
        begin
          Resolv.getaddress(host.hostname)
          true
        rescue Resolv::ResolvError
          false
        end
      end

      # If you would like to run tests that expect 400 or even 500 responses,
      # apply this method to remove the <tt>:raise_error</tt> middleware.
      def remove_error_checking(connection=self.connection)
        connection.builder.delete(Faraday::Response::RaiseError)
      end

      def acquire_ssl_components(host=self.host)
        if !host.is_a?(Unix::Host)
          raise 'Can only acquire SSL certs if the host is a Unix::Host'
        end
        acquire_ca_cert(host)
        acquire_cert_and_key(host)
      end

      def acquire_ca_cert(host=self.host)
        @ssl['ca_file'] = Scooter::Utilities::BeakerUtilities.pe_ca_cert_file(host)
      end

      def acquire_cert_and_key(host=self.host)
        client_key = Scooter::Utilities::BeakerUtilities.pe_private_key(host)
        client_cert = Scooter::Utilities::BeakerUtilities.pe_hostcert(host)
        @ssl['client_key']  = OpenSSL::PKey.read(client_key)
        @ssl['client_cert'] = OpenSSL::X509::Certificate.new(client_cert)
      end

      def add_ssl_components_to_connection(connection=self.connection)
        # return immediately if the ssl object is empty
        if ssl.empty?
          warn 'no ssl keys defined, the connection object will not be modified'
          return
        end
        # enforce the scheme to be https, since we are adding ssl components to
        # the connection object
        connection.url_prefix.scheme = 'https'

        @ssl.each do |k, v|
          connection.ssl[k] = v
        end

        if host.is_a?(Unix::Host)
          if connection.url_prefix.host == Scooter::Utilities::BeakerUtilities.get_public_ip(host) && connection.ssl['verify'] == nil
            # Because we are connecting to the dashboard by IP address, SSL verification
            # against the CA will fail. Disable verifying against it for now until a better
            # fix can be found.
            connection.ssl['verify'] = false
          end
        end
      end

    end
  end
end