%w( v1 ).each do |lib|
  require "scooter/httpdispatchers/activity/v1/#{lib}"
end

module Scooter
  module HttpDispatchers
    module Activity
     include Scooter::HttpDispatchers::Activity::V1

     def set_activity_service_path(connection=self.connection)
       set_url_prefix
       if is_certificate_dispatcher? || has_token?
         connection.url_prefix.path = '/activity-api'
       else
         connection.url_prefix.path = '/rbac/activity-api'
       end
     end

    end
  end
end
