module Beaker
  module Http

    # == Beaker::Http::Connection object instantiation examples
    # These examples are for using the Connection object directly. If you are trying to use
    # this from within a test, consider using the
    # {Beaker::DSL::Helpers::WebHelpers DSL constructors} instead.
    # @see Beaker::DSL::Helpers::WebHelpers
    class Connection
      include Beaker::Http::Helpers
      extend Forwardable

      attr_reader :connection

      # Beaker::Http::Connection objects can be instantiated with object that
      # utilizes a  object for easier setup during testing.
      #
      # @param [Hash] options Typically the global options provided by Beaker.
      # @option options [Beaker::Logger] :logger
      # @option options [Boolean] :log_http_bodies
      def initialize(options)
        @connection = create_default_connection(options)
      end

      def_delegators :connection, :get, :post, :put, :delete, :head, :patch, :url_prefix, :url_prefix=, :ssl

      def create_default_connection(options)
        Faraday.new do |conn|
          conn.request :json

          conn.response :follow_redirects
          conn.response :raise_error
          conn.response :json, :content_type => /\bjson$/

          # We can supply a third argument, a Hash with key of :bodies set to true or false,
          # to configure whether or not to log http bodies in requests and responses.
          # However, to uncomplicate things, we will just use the default
          # set in the middleware and not allow the http log level to be set
          # independently of the beaker log level. If we find that we should allow setting
          # of http bodies independent of the beaker log level, we should expose that setting
          # here.
          conn.response :faraday_beaker_logger, options[:logger]

          conn.adapter :net_http
        end
      end

      # If you would like to run tests that expect 400 or even 500 responses,
      # apply this method to remove the <tt>:raise_error</tt> middleware.
      def remove_error_checking
        connection.builder.delete(Faraday::Response::RaiseError)
        nil
      end

      def set_cacert(ca_file)
        ssl['ca_file'] = ca_file
        url_prefix.scheme = 'https'
      end

      def set_client_key(client_key)
        ssl['client_key'] = client_key
      end

      def set_client_cert(client_cert)
        ssl['client_cert'] = client_cert
      end

      # Use this method if you are connecting as a user to the system; it will
      # provide the correct SSL context but not provide authentication.
      def configure_cacert_with_puppet(host)
        set_cacert(get_host_cacert(host))
        connection.host = host.hostname
        nil
      end

      # Use this method if you want to connect to the system using certificate
      # based authentication. This method will provide the ssl context and use
      # the private key and cert from the host provided for authentication.
      def configure_private_key_and_cert_with_puppet(host)
        configure_cacert_with_puppet(host)

        client_key_raw = get_host_private_key(host)
        client_cert_raw = get_host_cert(host)

        ssl['client_key'] = OpenSSL::PKey.read(client_key_raw)
        ssl['client_cert'] = OpenSSL::X509::Certificate.new(client_cert_raw)

        nil
      end

    end
  end
end
