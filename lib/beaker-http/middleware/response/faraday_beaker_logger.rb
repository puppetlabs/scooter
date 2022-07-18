module Beaker
  module Http
    class FaradayBeakerLogger < Faraday::Response::Middleware
      extend Forwardable

      DEFAULT_OPTIONS = { :bodies => true }

      def initialize(app, logger, options = {} )
        super(app)
        @logger = logger
        @options = DEFAULT_OPTIONS.merge(options)
      end

      def_delegators :@logger, :trace, :debug, :info, :notify, :warn

      def call(env)
        @start_time = Time.now
        info "#{env.method.upcase}: #{env.url.to_s}"
        debug "REQUEST HEADERS:\n#{dump_headers env.request_headers}"
        debug "REQUEST BODY:\n#{dump_body env[:body]}" if env[:body] && log_body?(:request)
        super
      end

      def on_complete(env)
        info "RESPONSE CODE: #{env.status.to_s}"
        debug "ELAPSED TIME: #{Time.now - @start_time}"
        debug "RESPONSE HEADERS:\n#{dump_headers env.response_headers}"
        debug "RESPONSE BODY:\n#{dump_body env[:body]}" if env[:body] && log_body?(:response)
      end
      private

      def dump_headers(headers)
        headers.map { |k, v| "#{k}: #{v.inspect}" }.join("\n")
      end

      def pretty_inspect(body)
        require 'pp' unless body.respond_to?(:pretty_inspect)
        body.pretty_inspect
      end

      def dump_body(body)
        if body.respond_to?(:to_str)
          body.to_str
        else
          pretty_inspect(body)
        end
      end

      def log_body?(type)
        case @options[:bodies]
        when Hash then @options[:bodies][type]
        else @options[:bodies]
      end
    end

    end
  end
end

Faraday::Response.register_middleware :faraday_beaker_logger => lambda { Beaker::Http::FaradayBeakerLogger }
