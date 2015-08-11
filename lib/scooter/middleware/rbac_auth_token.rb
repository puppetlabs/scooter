module Faraday
  # This middleware checks for tokens and adds them to the request when found.
  # To include this correctly, you will need to pass the dispatcher itself to
  # the initialize method so it can read if the dispatcher has tokens or not.
  # Beyond just the token itself, it also checks the dispatcher if the
  # instance variable <i>send_auth_token_as_query_param</i> is set to true.
  # Otherwise, it will always attach it as an X-Authentication header.
  class RbacAuthToken < Faraday::Middleware
    attr_reader :dispatcher


    # @param app() Structural requirement for Faraday::Middleware initialization
    # @param dispatcher(Scooter::HttpDispatchers::ConsoleDispatcher required)
    #   Required param so that the middleware can check to see if there is a
    #   token set in the implementing dispatcher class. Will work with
    #   <i>ConsoleDispatcher</i>.
    def initialize(app, dispatcher)
      super(app)
      @dispatcher = dispatcher
    end

    def call(env)
      if dispatcher.token && dispatcher.send_auth_token_as_query_param
        query_array = [['token', dispatcher.token]]
        URI.decode_www_form(env.url.query).each {|tuple| query_array << tuple} if env.url.query
        env.url.query = URI.encode_www_form(query_array)
      elsif dispatcher.token
        env.request_headers['X-Authentication'] = dispatcher.token
      end
      @app.call env
    end
  end
end

Faraday::Request.register_middleware :rbac_auth_token => lambda { Faraday::RbacAuthToken }
