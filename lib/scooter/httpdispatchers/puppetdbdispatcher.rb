%w( v1 ).each do |lib|
  require "scooter/httpdispatchers/puppetdb/v1/#{lib}"
end
module Scooter
  module HttpDispatchers
    class PuppetdbDispatcher < HttpDispatcher

      include Scooter::HttpDispatchers::PuppetdbDispatcher::V1
      def set_puppetdb_path(connection=self.connection)
        set_url_prefix
        connection.url_prefix.path = '/pdb'
        connection.url_prefix.port = 8081
      end
    end
  end
end
