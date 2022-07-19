require 'spec_helper'

module Scooter

  describe Scooter::HttpDispatchers::Rbac do

    let(:host) { double('host') }
    let(:credentials) { double('credentials') }
    let(:user_list) {
      [
        {
          :email        => "",
          :is_revoked   => false,
          :last_login   => nil,
          :is_remote    => false,
          :login        => "api_user",
          :is_superuser => true,
          :id           => "af94921f-bd76-4b58-b5ce-e17c029a2790",
          :role_ids     => [
            1
          ],
          :display_name => "API User",
          :is_group     => false
        },
        {
          :email        => "",
          :is_revoked   => false,
          :last_login   => "2016-06-09T19 =>14 =>25.923Z",
          :is_remote    => false,
          :login        => "admin",
          :is_superuser => true,
          :id           => "42bf351c-f9ec-40af-84ad-e976fec7f4bd",
          :role_ids     => [
            1
          ],
          :display_name => "Administrator",
          :is_group     => false
        }
      ]
    }
    let(:role_list) {
      [
        {
          :description  => "Manage users and their permissions, and create and modify node groups and other objects.",
          :user_ids     => [
            "42bf351c-f9ec-40af-84ad-e976fec7f4bd",
            "af94921f-bd76-4b58-b5ce-e17c029a2790"
          ],
          :group_ids    => [],
          :display_name => "Administrators",
          :id           => 1,
          :permissions  => [
            {
              :object_type => "console_page",
              :action      => "view",
              :instance    => "*"
            },
            {
              :object_type => "node_groups",
              :action      => "modify_children",
              :instance    => "*"
            },
            {
              :object_type => "puppet_agent",
              :action      => "run",
              :instance    => "*"
            },
            {
              :object_type => "users",
              :action      => "edit",
              :instance    => "*"
            },
            {
              :object_type => "roles",
              :action      => "edit",
              :instance    => "*"
            },
            {
              :object_type => "users",
              :action      => "create",
              :instance    => "*"
            },
            {
              :object_type => "node_groups",
              :action      => "set_environment",
              :instance    => "*"
            },
            {
              :object_type => "user_groups",
              :action      => "import",
              :instance    => "*"
            },
            {
              :object_type => "roles",
              :action      => "create",
              :instance    => "*"
            },
            {
              :object_type => "users",
              :action      => "reset_password",
              :instance    => "*"
            },
            {
              :object_type => "directory_service",
              :action      => "edit",
              :instance    => "*"
            },
            {
              :object_type => "cert_requests",
              :action      => "accept_reject",
              :instance    => "*"
            },
            {
              :object_type => "roles",
              :action      => "edit_members",
              :instance    => "*"
            },
            {
              :object_type => "node_groups",
              :action      => "edit_classification",
              :instance    => "*"
            },
            {
              :object_type => "users",
              :action      => "disable",
              :instance    => "*"
            },
            {
              :object_type => "tokens",
              :action      => "override_lifetime",
              :instance    => "*"
            },
            {
              :object_type => "nodes",
              :action      => "view_data",
              :instance    => "*"
            },
            {
              :object_type => "environment",
              :action      => "deploy_code",
              :instance    => "*"
            },
            {
              :object_type => "nodes",
              :action      => "edit_data",
              :instance    => "*"
            },
            {
              :object_type => "node_groups",
              :action      => "edit_child_rules",
              :instance    => "*"
            },
            {
              :object_type => "orchestration",
              :action      => "use",
              :instance    => "*"
            },
            {
              :object_type => "user_groups",
              :action      => "delete",
              :instance    => "*"
            },
            {
              :object_type => "node_groups",
              :action      => "view",
              :instance    => "*"
            }
          ]
        },
        {
          :description  => "Create and modify node groups and other objects.",
          :user_ids     => [],
          :group_ids    => [],
          :display_name => "Operators",
          :id           => 2,
          :permissions  => [
            {
              :object_type => "tokens",
              :action      => "override_lifetime",
              :instance    => "*"
            },
            {
              :object_type => "cert_requests",
              :action      => "accept_reject",
              :instance    => "*"
            },
            {
              :object_type => "node_groups",
              :action      => "view",
              :instance    => "*"
            },
            {
              :object_type => "node_groups",
              :action      => "edit_classification",
              :instance    => "*"
            },
            {
              :object_type => "node_groups",
              :action      => "modify_children",
              :instance    => "*"
            },
            {
              :object_type => "puppet_agent",
              :action      => "run",
              :instance    => "*"
            },
            {
              :object_type => "environment",
              :action      => "deploy_code",
              :instance    => "*"
            },
            {
              :object_type => "node_groups",
              :action      => "set_environment",
              :instance    => "*"
            },
            {
              :object_type => "orchestration",
              :action      => "use",
              :instance    => "*"
            },
            {
              :object_type => "console_page",
              :action      => "view",
              :instance    => "*"
            },
            {
              :object_type => "node_groups",
              :action      => "edit_child_rules",
              :instance    => "*"
            }
          ]
        },
        {
          :description  => "Test delete role functionality",
          :user_ids     => [],
          :group_ids    => [],
          :display_name => "Dummy role",
          :id           => 13,
          :permissions  => [
            {
              :object_type => "console_page",
              :action      => "view",
              :instance    => "*"
            }]
        }
      ]
    }
    let(:group_list) {
      []
    }

    subject { HttpDispatchers::ConsoleDispatcher.new(host, credentials) }

    context 'with a beaker host passed in' do

      let(:logger) { double('logger')}
      unixhost = { roles:     ['test_role'],
                   'platform' => 'debian-7-x86_64' }
      let(:host) { Beaker::Host.create('test.com', unixhost, {:logger => logger}) }
      let(:host2) { Beaker::Host.create('test2.com', unixhost, {:logger => logger}) }
      let(:credentials) { { login: 'Ziggy', password: 'Stardust' } }

      before do
        allow_any_instance_of(Beaker::Http::FaradayBeakerLogger).to receive(:info) { true }
        allow_any_instance_of(Beaker::Http::FaradayBeakerLogger).to receive(:debug) { true }
        allow_any_instance_of(HttpDispatchers::ConsoleDispatcher).to receive(:configure_private_key_and_cert_with_puppet) { true }
        # Since we mocked the cert configuration action, we need to fixup the url_prefix
        # to be the proper scheme and object class, HTTPS instead of HTTP
        subject.url_prefix.scheme = 'https'
        subject.url_prefix = URI.parse(subject.connection.url_prefix.to_s)
        expect(subject).to be_kind_of(HttpDispatchers::ConsoleDispatcher)
      end

      describe '.acquire_token_with_credentials' do
        before do
          stub_request(:post, /rbac-api\/v1\/auth\/token/).
            to_return(status: 200, body: { "token" => "blah"}.to_json, headers: {"Content-Type"=> "application/json"})
        end
        it 'sets the token instance variable for the dispatcher' do
          expect { subject.acquire_token_with_credentials }.not_to raise_error
          expect(subject.token).to eq('blah')
        end
        it 'accepts an optional lifetime parameter' do
          expect { subject.acquire_token_with_credentials('600') }.not_to raise_error
          expect(subject.token).to eq('blah')
        end
      end

      describe 'ensure failure to get a token does not set the token instance variable' do
        before do
          # find the index of the default Faraday::Adapter::NetHttp handler
          # and replace it with the Test adapter
#           index = subject.connection.builder.handlers.index(Faraday::Adapter::NetHttp)
#           subject.connection.builder.swap(index, Faraday::Adapter::Test) do |stub|
#             stub.post('/rbac-api/v1/auth/token') { [401, {}, 'unauthorized'] }
#           end
          stub_request(:post, 'rbac-api\/v1\/auth\/token').
            to_return(status: 401, body: 'unauthorized', headers: {})
        end
        it 'the token variable should still be nil for a failed request' do
          expect { subject.acquire_token_with_credentials }.to raise_error(WebMock::NetConnectNotAllowedError)
          expect(subject.token).to eq(nil)
        end
      end

      describe '.delete_role_by_name' do
        before do
          stub_request(:delete, /rbac-api\/v1\/roles/).
            to_return(status: 200, body: {}.to_json, headers: {})
          stub_request(:get, /rbac-api\/v1\/roles/).
            to_return(status: 200, body: role_list.to_json, headers: {"Content-Type"=> "application/json"})
        end
        it 'returns 200 when deleting role' do
          response = subject.delete_role_by_name('Dummy role')
          expect(response.status).to eq(200)
        end
        it 'returns 400 when getting deleted role' do
          response = subject.get_role_by_name('Dummy role')
          expect(response['display_name']).to eq("Dummy role")
        end
      end

      describe '.get_group_data_by_name' do
        let(:groups_array) {
          [{ "user_ids"     => [],
             "role_ids"     => [],
             "display_name" => "",
             "is_superuser" => false,
             "is_remote"    => true,
             "is_group"     => true,
             "login"        => "group1",
             "id"           => "09c2c1fd-ea01-4555-bc7b-a8f25c4511f8" },
             { "user_ids"     => [],
               "role_ids"     => [],
               "display_name" => "",
               "is_superuser" => false,
               "is_remote"    => true,
               "is_group"     => true,
               "login"        => "group2",
               "id"           => "09c2c1fd-ea01-4555-bc7b-a8f25c4511f7" }]
        }
        before do
          expect(subject).to receive(:get_list_of_groups) { groups_array }
        end
        it 'can find group1 in the payload' do
          expect(subject.get_group_data_by_name('group1')).to eq(groups_array[0])
        end
        it 'can find group2 in the payload' do
          expect(subject.get_group_data_by_name('group2')).to eq(groups_array[1])
        end
        it 'returns nil for group3, who is not in the payload' do
          expect(subject.get_group_data_by_name('group3')).to eq(nil)
        end
      end

      describe '.rbac_database_matches_self' do


        before do
          stub_request(:get, "https://test.com:4433/rbac-api/v1/users").
            to_return(status: 200, body: user_list.to_json, headers: {"Content-Type"=> "application/json"})
          stub_request(:get, "https://test2.com:4433/rbac-api/v1/users").
            to_return(status: 200, body: user_list.dup.push('another_array_item').to_json, headers: {"Content-Type"=> "application/json"})

          stub_request(:get, "https://test.com:4433/rbac-api/v1/groups").
            to_return(status: 200, body: group_list.to_json, headers: {"Content-Type"=> "application/json"})
          stub_request(:get, "https://test2.com:4433/rbac-api/v1/groups").
            to_return(status: 200, body: group_list.dup.push('another_array_item').to_json, headers: {"Content-Type"=> "application/json"})

          stub_request(:get, "https://test.com:4433/rbac-api/v1/roles").
            to_return(status: 200, body: role_list.to_json, headers: {"Content-Type"=> "application/json"})
          stub_request(:get, "https://test2.com:4433/rbac-api/v1/roles").
            to_return(status: 200, body: role_list.dup.push('another_array_item').to_json, headers: {"Content-Type"=> "application/json"})

          expect(subject).to receive(:is_resolvable).exactly(6).times.and_return(true)
        end
        it 'compare with self' do
          expect(subject.rbac_database_matches_self?(host)).to be_truthy
        end

        it 'compare with different' do
          expect(subject.host.logger).to receive(:warn).with /Users do not match/
          expect(subject.rbac_database_matches_self?(host2)).to be_falsey
        end
      end
    end
  end
end
