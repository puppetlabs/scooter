module Scooter
  module HttpDispatchers
    module Rbac
      module V1
        # Methods defined here are broken out from the rest of the RBAC
        # endpoints because they use a ldapdispatcher object to determine
        # various settings for the ds endpoint.
        module DirectoryService

          def ds_default_settings(ldapdispatcher)
            base_dn_to_chomp = ',' + ldapdispatcher.default_base_dn
            user_rdn = ldapdispatcher.users_dn.chomp(base_dn_to_chomp)
            group_rdn = ldapdispatcher.groups_dn.chomp(base_dn_to_chomp)
            settings                      = {
                "id"                     => 1,
                "display_name"           => 'test_ds',
                "help_link"              => 'https://example.com',
                "hostname"               => ldapdispatcher.host,
                "port"                   => ldapdispatcher.port,
                "login"                  => ldapdispatcher.admin_dn,
                "password"               => ldapdispatcher.default_ds_password,
                "connect_timeout"        => 20,
                "ssl"                    => true,
                "base_dn"                => ldapdispatcher.default_base_dn,
                "user_lookup_attr"       => 'cn',
                "user_email_attr"        => 'mail',
                "user_display_name_attr" => 'displayName',
                "group_object_class"     => '*',
                "group_name_attr"        => 'name',
                "group_member_attr"      => 'uniqueMember',
                "group_lookup_attr"      => 'cn',
                "user_rdn"               => user_rdn,
                "group_rdn"              => group_rdn
              }

              # Change the group_member_attr to just member if windows is the
              # directory service, because AD doesn't support the attribute
              # uniqueMember
              settings['group_member_attr'] = 'member' if ldapdispatcher.is_windows_ad?
              settings
          end

          def attach_ds_to_rbac(ldapdispatcher=nil, options={})
            settings = ds_default_settings(ldapdispatcher) if ldapdispatcher
            settings.merge!(options)

            set_rbac_path
            @connection.put('v1/ds') do |req|
              req.body = settings
            end
          end

          def test_attach_ds_to_rbac(ldapdispatcher=nil, options={})
            settings = ds_default_settings(ldapdispatcher) if ldapdispatcher
            settings.merge!(options)

            set_rbac_path
            @connection.put('v1/ds/test') do |req|
              req.body = settings
            end
          end

        end
      end
    end
  end
end

