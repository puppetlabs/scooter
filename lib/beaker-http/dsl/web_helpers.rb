module Beaker::DSL::Helpers::WebHelpers

  # Generates a new http connection object, using the ever-present options hash to
  # configure the connection.
  #
  # @param host [Beaker::Host optional] supply a SUT host object; will use puppet on host
  #    to configure certs, and use the options in the host object instead of the global.
  # @return [Beaker::Http::Connection] an object wrapping the Faraday::Connection object.
  def generate_new_http_connection(host = nil)
    if host
      raise ArgumentError.new "host must be Beaker::Host, not #{host.class}" if !host.is_a?(Beaker::Host)
      connection = Beaker::Http::Connection.new(host.options)
      connection.configure_private_key_and_cert_with_puppet(host)
      connection
    else
      Beaker::Http::Connection.new(options)
    end
  end

  # Make a single http request and discard the http connection object. Returns a Faraday::Response
  # object that can be introspected for all response information.
  #
  # @param url [String] String that will be parsed into a URI object.
  # @param request_method [Symbol] Represents any valid http verb.
  # @param cert [OpenSSL::X509::Certificate] Certifcate for authentication.
  # @param key [OpenSSL::PKey::RSA] Private Key for authentication.
  # @param body [String, Hash] For requests that can send a body. Strings are sent unformatted and
  #    Hashes are JSON.parsed by the Faraday Middleware.
  # @param [Hash] options Hash of options extra options for the request
  # @option options [Boolean] :read_timeout How long to wait before closing the connection.
  # @return [Faraday::Response]
  def http_request(url, request_method, cert=nil, key=nil, body=nil, options={})
    connection = generate_new_http_connection


    connection.url_prefix = URI.parse(url)

    if cert
      if cert.is_a?(OpenSSL::X509::Certificate)
        connection.ssl['client_cert'] = cert
      else
        raise TypeError, "cert must be an OpenSSL::X509::Certificate object, not #{cert.class}"
      end
    end

    if key
      if key.is_a?(OpenSSL::PKey::RSA)
        connection.ssl['client_key'] = key
      else
        raise TypeError, "key must be an OpenSSL::PKey:RSA object, not #{key.class}"
      end
    end

    # ewwww
    connection.ssl[:verify] = false

    connection.connection.options.timeout = options[:read_timeout] if options[:read_timeout]

    response = connection.send(request_method) { |conn| conn.body = body }
    response
  end
end
