%w( ldap_fixtures ).each do |lib|
  require "scooter/ldap/#{lib}"
end
module Scooter
  module LDAP

    DEFAULT_DS_PORT = 636
    DEFAULT_USER_PASSWORD = 'Puppet11'

    # == Quick-start guide for the impatient
    # === Quick example creating an LDAPDispatcher object with a beaker config:
    #
    #  #Example beaker configuration
    #  #
    #  #HOSTS:
    #  #  win_2008_r2_x64:
    #  #    roles:
    #  #      - directory_service
    #  #    platform: windows-2008r2-x86_64
    #
    #  require 'scooter'
    #  ldapdispatcher = Scooter::LDAP::LDAPDispatcher.new(directory_service)
    #  # If you are not using the default static fixtures, you probably want
    #  # to change the credentials for your LDAP instance
    #  ldapdispatcher.auth(user_dn, password)
    #  # This is the normal method you would use to set up a standard test
    #  # environment, with groups of writers(poets, lyricists, novelists)
    #  # to populate your directory_service
    #  ldapdispatcher.create_default_test_groups_and_users
    class LDAPDispatcher < Net::LDAP


      attr_accessor :test_uid
      attr_reader :ds_type, :users_dn, :groups_dn, :ds_users

      # Instantiating an object of type Scooter::LDAP::LDAPDispatcher extends
      # the Net::LDAP class to include helper methods to make test setup and
      # cleanup more consistent and reliable for beaker tests involving the
      # Puppet RBAC Service. LDAPDispatcher objects require either a Unix::Host
      # or Windows::Host object passed in as a parameter, which will dictate how
      # helper methods construct a test environment of groups and users.
      #
      # Unlike the Net::LDAP, LDAPDispatcher <i>does</i> test the network
      # connection during initialization and raises a warning if it fails.
      # @param host [Unix::Host, Windows::Host] the DS host object defined in
      #   your Beaker config
      # @param options [hash] any params you would like to override; you are
      #   likely to want to do this if you are not using the static Puppet LDAP
      #   fixtures
      def initialize(host, options={})
        
        # All initialized LDAPDispatcher objects will have test_uids to ensure
        # no collisions when creating entries in the directory services.
        @test_uid = Scooter::Utilities::RandomString.generate(4)
        if host.is_a? Windows::Host
          @ds_type = :ad
        elsif host.is_a? Unix::Host
          @ds_type = :openldap
        else
          raise "host must be Unix::Host or Windows::Host, not #{host.class}"
        end

        generated_args = {}
        generated_args[:host] = host.reachable_name
        generated_args[:port] = DEFAULT_DS_PORT
        generated_args[:encryption] = {:method => :simple_tls}
        generated_args[:base] = return_default_base

        generated_args.merge!(options)
        super(generated_args)

        # If we didn't pass in an :auth hash, generate the default settings
        # using the auth method of Net::LDAP
        if !options[:auth]
          self.auth admin_dn, return_default_password
        end

        if !bind
          warn "Problem binding to #{host}, #{get_operation_result}\n
                username: #{admin_dn}, pw: #{return_default_password}"
        end
      end

      def return_default_password
        "Puppet11"
      end

      def return_default_base
        'dc=delivery,dc=puppetlabs,dc=net'
      end

      def is_openldap?
        true if @ds_type == :openldap
      end

      def is_windows_ad?
        true if @ds_type == :ad
      end

      def admin_dn
        if is_windows_ad?
          "cn=Administrator,cn=Users,#{return_default_base}"
        else
          "cn=admin,#{return_default_base}"
        end
      end

      def create_temp_ou(base_string='test_')
        ou = base_string + @test_uid
        dn = "ou=#{ou},#{self.base}"
        attr = {:objectClass => ['top', 'organizationalUnit'],
                :ou => ou}
        add(:dn => dn, :attributes => attr)

        if get_operation_result.code != 0
          raise "OU creation failed: #{get_operation_result}, #{dn}"
        end

        dn
      end

      # This method should execute after a test's completion; the group's ou
      # and users's ou will be deleted, as will any entity with those
      # respective ou's in their distinguished name.
      # === Example beaker teardown
      #
      #  Example beaker teardown
      #
      #  teardown do
      #    ldapdispatcher.delete_users_and_groups_organizational_units
      #  end
      def delete_users_and_groups_organizational_units
        delete_all_dn_entries(@groups_dn)
        delete_all_dn_entries(@users_dn)
      end

      def delete_all_dn_entries(dn)
        entries = search(:base => dn, :attributes => ['dn'])
        entries.each do |entry|
          delete :dn => entry.dn
        end

        #This needs to be repeated because it may have failed deleting a group
        #that still had users associated.
        entries.each do |entry|
          delete :dn => entry.dn
        end

        #This request should return nil; all entities with the dn provided
        #should now be deleted.
        entries = search(:base => dn, :attributes => ['dn'])
        if entries != nil
          raise "Problem deleting all entries for this dn: #{dn}"
        end
      end

      def create_ds_user(attributes, users_dn=self.users_dn)
        default_attributes = {:objectClass => ['top',
                                               'person',
                                               'organizationalPerson',
                                               'inetOrgPerson']}

        if is_windows_ad?
          default_attributes[:userAccountControl] = ['544']
        end

        default_attributes.merge!(attributes)

        add(:dn => "cn=#{default_attributes[:cn]},#{users_dn}",
            :attributes => default_attributes)

        if get_operation_result.code != 0
          raise "Creating user failed: #{get_operation_result}\n
                #{default_attributes}"
        end
      end

      def create_ds_group(attributes, groups_dn=self.groups_dn)

        #When Openldap, you must specify :member entries in the attributes
        default_attributes = {:objectClass => ["top", "groupOfUniqueNames"]}

        if is_windows_ad?
          default_attributes[:objectClass] = ["top", "group"]
        end

        default_attributes.merge!(attributes)

        add(:dn => "cn=#{default_attributes[:cn]},#{groups_dn}",
            :attributes => default_attributes)

        if get_operation_result.code != 0
          raise "Creating group failed: #{get_operation_result},\n
                #{default_attributes}"
        end
      end

      def create_ou_for_users_and_groups
        @users_dn = create_temp_ou('users')
        @groups_dn = create_temp_ou('groups')
      end

      # This is the primary method most tests will use. It creates two
      # organizational units, or ou's, to base all your testing around. There is
      # one ou for groups and one for users. Most testing can be covered by
      # simply running the method <tt>create_default_test_groups_and_users</tt>.
      def create_default_test_groups_and_users

        create_ou_for_users_and_groups

        create_default_users

        if is_windows_ad?
          create_windows_ad_default_users_and_test_groups
        elsif is_openldap?
          create_openldap_default_users_and_test_groups
        end

      end

      def create_default_users
        users = Scooter::LDAP::LDAPFixtures.users(@test_uid)

        users.each do |name, hash|
          create_ds_user(hash)
          update_user_password("CN=#{hash[:cn]},#{users_dn}", DEFAULT_USER_PASSWORD)
          hash[:password] = DEFAULT_USER_PASSWORD
        end
        @ds_users = users
      end

      #This is used to encode passwords for Windows AD
      #See URL: http://msdn.microsoft.com/en-us/library/cc223248.aspx
      def str_to_unicode_pwd(str) #:nodoc:
        ('"' + str + '"').encode("utf-16le").force_encoding("utf-8")
      end

      def update_user_password(user_dn, password) #:nodoc:
        if is_windows_ad?
          password = str_to_unicode_pwd(password)
          ops = [[:replace, :unicodePwd, password]]
        else
          ops = [[:replace, :userPassword, password]]
        end

        modify :dn => user_dn, :operations => ops

        if get_operation_result.code != 0
          raise "Updating password failed: #{get_operation_result}\n
                #{ops}"
        end
      end

      private
      def create_openldap_default_users_and_test_groups #:nodoc:

        #add novelists
        novelists =["cn=#{ds_users['arthur'][:cn]},#{users_dn}",
                    "cn=#{ds_users['howard'][:cn]},#{users_dn}",
                    "cn=#{ds_users['oscar'][:cn]},#{users_dn}"]

        create_ds_group({ :cn           => "novelists#{@test_uid}",
                          :uniqueMember => novelists })

        #add poets
        poets = ["cn=#{ds_users['sylvia'][:cn]},#{users_dn}",
                 "cn=#{ds_users['jorge'][:cn]},#{users_dn}",
                 "cn=#{ds_users['oscar'][:cn]},#{users_dn}"]

        create_ds_group({ :cn           => "poets#{@test_uid}",
                          :uniqueMember => poets })

        #add lyricists
        lyricists = ["cn=#{ds_users['stephen'][:cn]},#{users_dn}"]

        create_ds_group({ :cn           => "lyricists#{@test_uid}",
                          :uniqueMember => lyricists })

        #add writers
        writers = ["cn=#{ds_users['guillermo'][:cn]},#{users_dn}",
                   "cn=novelists#{test_uid},#{groups_dn}",
                   "cn=poets#{test_uid},#{groups_dn}",
                   "cn=lyricists#{test_uid},#{groups_dn}"]

        create_ds_group({ :cn           => "writers#{@test_uid}",
                          :uniqueMember => writers })

      end

      def create_windows_ad_default_users_and_test_groups #:nodoc:

        writers_cn = "writers#{@test_uid}"
        poets_cn = "poets#{@test_uid}"
        novelists_cn = "novelists#{@test_uid}"
        lyricists_cn = "lyricists#{@test_uid}"

        create_ds_group(:cn => lyricists_cn)
        create_ds_group(:cn => novelists_cn)
        create_ds_group(:cn => poets_cn)
        create_ds_group(:cn => writers_cn)

        add_attribute("cn=#{writers_cn},#{groups_dn}",
                      :member,
                      "cn=#{lyricists_cn},#{groups_dn}")

        add_attribute("cn=#{writers_cn},#{groups_dn}",
                      :member,
                      "cn=#{poets_cn},#{groups_dn}")

        add_attribute("cn=#{writers_cn},#{groups_dn}",
                      :member,
                      "cn=#{novelists_cn},#{groups_dn}")

        add_attribute("cn=#{novelists_cn},#{groups_dn}",
                      :member,
                      "cn=#{ds_users['howard'][:cn]},#{users_dn}")

        add_attribute("cn=#{novelists_cn},#{groups_dn}",
                      :member,
                      "cn=#{ds_users['arthur'][:cn]},#{users_dn}")

        add_attribute("cn=#{novelists_cn},#{groups_dn}",
                      :member,
                      "cn=#{ds_users['oscar'][:cn]},#{users_dn}")

        add_attribute("cn=#{poets_cn},#{groups_dn}",
                      :member,
                      "cn=#{ds_users['sylvia'][:cn]},#{users_dn}")

        add_attribute("cn=#{poets_cn},#{groups_dn}",
                      :member,
                      "cn=#{ds_users['jorge'][:cn]},#{users_dn}")

        add_attribute("cn=#{poets_cn},#{groups_dn}",
                      :member,
                      "cn=#{ds_users['oscar'][:cn]},#{users_dn}")

        add_attribute("cn=#{writers_cn},#{groups_dn}",
                      :member,
                      "cn=#{ds_users['guillermo'][:cn]},#{users_dn}")

        add_attribute("cn=#{lyricists_cn},#{groups_dn}",
                      :member,
                      "cn=#{ds_users['stephen'][:cn]},#{users_dn}")

      end
    end
  end
end
