module Scooter
  module LDAP
    class LDAPFixtures
      attr_reader :users


      def self.users(test_uid=nil)
        { 'howard'    =>
              { :cn          => "howard#{test_uid}",
                :sn          => "lovecraft",
                :displayName => "Howard P. Lovecraft#{test_uid}",
                :mail        => "howard@example.com"
              },
          'sylvia'    =>
              { :cn          => "sylvia#{test_uid}",
                :sn          => "plath",
                :displayName => "Sylvia Plath#{test_uid}",
                :mail        => "sylvia@example.com"
              },
          'guillermo' =>
              { :cn          => "guillermo#{test_uid}",
                :sn          => "del toro",
                :displayName => "Guillermo del Toro#{test_uid}",
                :mail        => "guillermo@example.com"
              },
          'jorge'     =>
              { :cn          => "jorge#{test_uid}",
                :sn          => "borges",
                :displayName => "Jorge Borges#{test_uid}",
                :mail        => "jorge@example.com"
              },
          'arthur'    =>
              { :cn          => "arthur#{test_uid}",
                :sn          => "doyle",
                :displayName => "Sir Arthur Conan Doyle#{test_uid}",
                :mail        => "arthur@example.com"
              },
          'oscar'     =>
              { :cn          => "oscar#{test_uid}",
                :sn          => 'wilde',
                :displayName => "Oscar Fingal O'Flahertie Wills Wilde#{test_uid}",
                :mail        => 'oscar@example.com'
              },
          'stephen'   =>
              { :cn          => "stephen#{test_uid}",
                :sn          => 'sondheim',
                :displayName => "Stephen Sondheim#{test_uid}",
                :mail        => 'stephen@example.com'
              },
          'tony'      =>
              { :cn          => "tony#{test_uid}",
                :sn          => "stark",
                :displayName => "Tony Stark#{test_uid}",
                :mail        => "tony@example.com"
              }
        }
      end
    end
  end
end