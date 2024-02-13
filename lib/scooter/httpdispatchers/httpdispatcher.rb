require 'resolv'

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
    class HttpDispatcher < Beaker::Http::Connection


      attr_accessor :connection, :host, :token, :send_auth_token_as_query_param, :faraday_logger
      # The only required parameter for the HttpDispatcher is the host, which
      # must be a Beaker::Host object. HttpDispatchers offer
      # support for automatically generating the required SSL components for the
      # Dispatcher if it is passed a Unix Host.
      #
      # @param host(Beaker::Host) The beaker host object you wish to communicate
      #   with.
      # @param log_level(Int) The desired log level
      # @param log_body(Boolean) Whether to log the body of responses
      def initialize(host, log_level=Logger::DEBUG, log_body=true)
        @connection = create_default_connection(host.options, log_body)
        @log_body = log_body
        @host = host
        configure_private_key_and_cert_with_puppet(host)

        set_url_prefix
        # In this conditional, if we are unable to resolve the hostname, we get the public IP address;
        # because public IP addresses will fail ssl verification, we explicitly turn that off. There
        # should be a better solution, but this has worked so far...
        if !is_resolvable
          connection.url_prefix.host = Scooter::Utilities::BeakerUtilities.get_public_ip(host)
          connection.ssl['verify'] = false
        end

        # The http-cookie library that the cookie-jar wraps requires that a
        # URI object be specifically a URI::HTTPS object. This changes the
        # default url_prefix in Faraday to be sub-classed from HTTPS, not plain
        # old HTTP. This should have no effect on any other middleware, as HTTPS
        # is just HTTP subclassed with different defaults.
        @connection.url_prefix = URI.parse(@connection.url_prefix.to_s)
      end

      def create_default_connection(options, log_body)
        Faraday.new do |conn|
          conn.request :rbac_auth_token, self
          conn.request :json

          conn.response :follow_redirects
          conn.response :raise_error
          conn.response :json, :content_type => /\bjson$/
          conn.response :faraday_beaker_logger, options[:logger], { :bodies => log_body }

          conn.use :cookie_jar

          conn.adapter :net_http
        end
      end

      def set_url_prefix(connection=self.connection)
        if host.is_a?(Unix::Host)
          connection.url_prefix.host = is_resolvable ? host.hostname : Scooter::Utilities::BeakerUtilities.get_public_ip(host)
        else
          connection.url_prefix.host = host.reachable_name
        end
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
    end
  end
end
