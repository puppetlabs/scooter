module Scooter
  module HttpDispatchers
    class PuppetdbDispatcher < HttpDispatcher
      # Methods here are generally representative of endpoints, and depending
      # on the method, return either a Faraday response object or some sort of
      # instance of the object created/modified.
      module V4

        # @param [String] ast_query_string - An AST query string:  https://docs.puppet.com/puppetdb/latest/api/query/v4/ast.html
        # @return [Object]
        def query_nodes(ast_query_string=nil)
          set_puppetdb_path
          @connection.post('query/v4/nodes') do |request|
            unless ast_query_string.nil?
              request.params['query'] = ast_query_string
            end
          end
        end

        # @param [String] ast_query_string - An AST query string:  https://docs.puppet.com/puppetdb/latest/api/query/v4/ast.html
        # @return [Object]
        def query_catalogs(ast_query_string=nil)
          set_puppetdb_path
          @connection.post('query/v4/catalogs') do |request|
            unless ast_query_string.nil?
              request.params['query'] = ast_query_string
            end
          end
        end

        # @param [String] ast_query_string - An AST query string:  https://docs.puppet.com/puppetdb/latest/api/query/v4/ast.html
        # @return [Object]
        def query_reports(ast_query_string=nil)
          set_puppetdb_path
          @connection.post('query/v4/reports') do |request|
            unless ast_query_string.nil?
              request.params['query'] = ast_query_string
            end
          end
        end

        # @param [String] ast_query_string - An AST query string:  https://docs.puppet.com/puppetdb/latest/api/query/v4/ast.html
        # @return [Object]
        def query_facts(ast_query_string=nil)
          set_puppetdb_path
          @connection.post('query/v4/facts') do |request|
            unless ast_query_string.nil?
              request.params['query'] = ast_query_string
            end
          end
        end
      end
    end
  end
end
