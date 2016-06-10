require 'spec_helper'

module Scooter

  describe Scooter::HttpDispatchers::Classifier do

    let(:host) { double('host') }
    let(:credentials) { double('credentials') }
    let(:node_list) { [
        {
            "name"      => "fbf2gpzzr4945ik.delivery.puppetlabs.net",
            "check_ins" => [
                {
                    "time"             => "2016-06-06T18:28:27.686Z",
                    "explanation"      => {
                        "00000000-0000-4000-8000-000000000000" => {
                            "value" => true,
                            "form"  => [
                                "and",
                                {
                                    "value" => true,
                                    "form"  => [
                                        "~",
                                        {
                                            "path"  => "name",
                                            "value" => "fbf2gpzzr4945ik.delivery.puppetlabs.net"
                                        },
                                        ".*"
                                    ]
                                }
                            ]
                        },
                        "a9649f0c-97bd-4394-964c-230a4b35f272" => {
                            "value" => true,
                            "form"  => [
                                "and",
                                {
                                    "value" => true,
                                    "form"  => [
                                        "~",
                                        {
                                            "path"  => "name",
                                            "value" => "fbf2gpzzr4945ik.delivery.puppetlabs.net"
                                        },
                                        ".*"
                                    ]
                                }
                            ]
                        },
                        "6c847b5c-51bc-49fa-ab1b-e20a9ef3474d" => {
                            "value" => true,
                            "form"  => [
                                "or",
                                {
                                    "value" => true,
                                    "form"  => [
                                        "=",
                                        {
                                            "path"  => "name",
                                            "value" => "fbf2gpzzr4945ik.delivery.puppetlabs.net"
                                        },
                                        "fbf2gpzzr4945ik.delivery.puppetlabs.net"
                                    ]
                                }
                            ]
                        },
                        "a07c4da1-9af7-4427-a99c-19efff80accb" => {
                            "value" => true,
                            "form"  => [
                                "or",
                                {
                                    "value" => true,
                                    "form"  => [
                                        "=",
                                        {
                                            "path"  => "name",
                                            "value" => "fbf2gpzzr4945ik.delivery.puppetlabs.net"
                                        },
                                        "fbf2gpzzr4945ik.delivery.puppetlabs.net"
                                    ]
                                }
                            ]
                        },
                        "6f1b8ba3-652c-40c6-a7c4-fe318352db93" => {
                            "value" => true,
                            "form"  => [
                                "or",
                                {
                                    "value" => true,
                                    "form"  => [
                                        "=",
                                        {
                                            "path"  => "name",
                                            "value" => "fbf2gpzzr4945ik.delivery.puppetlabs.net"
                                        },
                                        "fbf2gpzzr4945ik.delivery.puppetlabs.net"
                                    ]
                                }
                            ]
                        },
                        "b9e64b26-7b65-42f9-a9a1-bfbbfd4cc7a8" => {
                            "value" => true,
                            "form"  => [
                                "and",
                                {
                                    "value" => true,
                                    "form"  => [
                                        "~",
                                        {
                                            "path"  => [
                                                "fact",
                                                "aio_agent_version"
                                            ],
                                            "value" => "1.5.0.31"
                                        },
                                        ".+"
                                    ]
                                }
                            ]
                        },
                        "06042e9b-45c9-4add-bce1-d9034d5de16b" => {
                            "value" => true,
                            "form"  => [
                                "or",
                                {
                                    "value" => true,
                                    "form"  => [
                                        "=",
                                        {
                                            "path"  => "name",
                                            "value" => "fbf2gpzzr4945ik.delivery.puppetlabs.net"
                                        },
                                        "fbf2gpzzr4945ik.delivery.puppetlabs.net"
                                    ]
                                }
                            ]
                        },
                        "773c9b5a-e8c7-49ea-8931-f2e020383f21" => {
                            "value" => true,
                            "form"  => [
                                "or",
                                {
                                    "value" => true,
                                    "form"  => [
                                        "=",
                                        {
                                            "path"  => "name",
                                            "value" => "fbf2gpzzr4945ik.delivery.puppetlabs.net"
                                        },
                                        "fbf2gpzzr4945ik.delivery.puppetlabs.net"
                                    ]
                                }
                            ]
                        },
                        "329210bb-de3a-43f3-a732-73905f4e57ac" => {
                            "value" => true,
                            "form"  => [
                                "and",
                                {
                                    "value" => true,
                                    "form"  => [
                                        "~",
                                        {
                                            "path"  => [
                                                "fact",
                                                "aio_agent_version"
                                            ],
                                            "value" => "1.5.0.31"
                                        },
                                        ".+"
                                    ]
                                }
                            ]
                        },
                        "40b72723-f191-4153-b81c-1f6531c5a9cd" => {
                            "value" => true,
                            "form"  => [
                                "or",
                                {
                                    "value" => true,
                                    "form"  => [
                                        "=",
                                        {
                                            "path"  => "name",
                                            "value" => "fbf2gpzzr4945ik.delivery.puppetlabs.net"
                                        },
                                        "fbf2gpzzr4945ik.delivery.puppetlabs.net"
                                    ]
                                }
                            ]
                        }
                    },
                    "classification"   => {
                        "classes"     => {
                            "pe_repo"                                           => {},
                            "pe_repo::platform::el_7_x86_64"                    => {},
                            "puppet_enterprise::profile::mcollective::agent"    => {},
                            "pe_console_prune"                                  => {
                                "prune_upto" => "30"
                            },
                            "puppet_enterprise::profile::puppetdb"              => {},
                            "puppet_enterprise::profile::agent"                 => {},
                            "puppet_enterprise::license"                        => {},
                            "puppet_enterprise::profile::orchestrator"          => {},
                            "puppet_enterprise::profile::master"                => {},
                            "puppet_enterprise::profile::master::mcollective"   => {},
                            "puppet_enterprise::profile::console"               => {},
                            "puppet_enterprise::profile::mcollective::peadmin"  => {},
                            "puppet_enterprise"                                 => {
                                "mcollective_middleware_hosts" => [
                                    "fbf2gpzzr4945ik.delivery.puppetlabs.net"
                                ],
                                "use_application_services"     => true,
                                "database_host"                => "fbf2gpzzr4945ik.delivery.puppetlabs.net",
                                "puppetdb_host"                => "fbf2gpzzr4945ik.delivery.puppetlabs.net",
                                "database_port"                => "5432",
                                "classifier_database_user"     => "DFGhjlkj",
                                "orchestrator_database_user"   => "Orc3Str8R",
                                "database_ssl"                 => true,
                                "activity_database_user"       => "adsfglkj",
                                "puppet_master_host"           => "fbf2gpzzr4945ik.delivery.puppetlabs.net",
                                "certificate_authority_host"   => "fbf2gpzzr4945ik.delivery.puppetlabs.net",
                                "console_port"                 => "443",
                                "rbac_database_user"           => "RbhNBklm",
                                "puppetdb_database_name"       => "pe-puppetdb",
                                "puppetdb_database_user"       => "mYpdBu3r",
                                "pcp_broker_host"              => "fbf2gpzzr4945ik.delivery.puppetlabs.net",
                                "puppetdb_port"                => "8081",
                                "database_cert_auth"           => false,
                                "console_host"                 => "fbf2gpzzr4945ik.delivery.puppetlabs.net"
                            },
                            "puppet_enterprise::profile::amq::broker"           => {},
                            "puppet_enterprise::profile::certificate_authority" => {}
                        },
                        "variables"   => {},
                        "environment" => "production"
                    },
                    "transaction_uuid" => "a3efb727-10e9-4bc0-b5f0-69ed74f30c22"
                }
            ]
        }
    ] }

    let(:group_list) { [
        {
            "parent"             => "00000000-0000-4000-8000-000000000000",
            "environment_trumps" => false,
            "name"               => "All Nodes",
            "rule"               => [
                "and",
                [
                    "~",
                    "name",
                    ".*"
                ]
            ],
            "variables"          => {},
            "id"                 => "00000000-0000-4000-8000-000000000000",
            "environment"        => "production",
            "classes"            => {}
        },
        {
            "parent"             => "aabb8071-df67-4340-aded-e4f598a3ca0b",
            "environment_trumps" => false,
            "name"               => "PE Certificate Authority",
            "rule"               => [
                "or",
                [
                    "=",
                    "name",
                    "fbf2gpzzr4945ik.delivery.puppetlabs.net"
                ]
            ],
            "variables"          => {},
            "id"                 => "06042e9b-45c9-4add-bce1-d9034d5de16b",
            "environment"        => "production",
            "classes"            => {
                "puppet_enterprise::profile::certificate_authority" => {}
            }
        }] }
    let(:environment_list) { [
        {
            "name"           => "agent-specified",
            "sync_succeeded" => true
        },
        {
            "name"           => "production",
            "sync_succeeded" => true
        }
    ] }
    let(:class_list) { [
        {
            "name"        => "pe_accounts",
            "environment" => "production",
            "parameters"  => {
                "manage_groups"  => "true",
                "manage_users"   => "true",
                "manage_sudoers" => "false",
                "data_store"     => "'namespace'",
                "data_namespace" => "'pe_accounts::data'",
                "sudoers_path"   => "'/etc/sudoers'"
            }
        },
        {
            "name"        => "pe_accounts::data",
            "environment" => "production",
            "parameters"  => {}
        },
        {
            "name"        => "pe_accounts::groups",
            "environment" => "production",
            "parameters"  => {
                "groups_hash" => nil
            }
        },
        {
            "name"        => "pe_concat::setup",
            "environment" => "production",
            "parameters"  => {}
        }] }

    subject { HttpDispatchers::ConsoleDispatcher.new(host, credentials) }

    context 'with a beaker host passed in' do

      unixhost = { roles:     ['test_role'],
                   'platform' => 'debian-7-x86_64' }
      let(:host) { Beaker::Host.create('test.com', unixhost, {}) }
      let(:credentials) { { login: 'Ziggy', password: 'Stardust' } }

      before do
        expect(Scooter::Utilities::BeakerUtilities).to receive(:pe_ca_cert_file).and_return('cert file')
        expect(subject).not_to be_nil
      end

      describe '.update_classes' do
        before do
          # find the index of the default Faraday::Adapter::NetHttp handler
          # and replace it with the Test adapter
          index = subject.connection.builder.handlers.index(Faraday::Adapter::Typhoeus)
          subject.connection.builder.swap(index, Faraday::Adapter::Test) do |stub|
            stub.post('/classifier-api/v1/update-classes') { [201, {}] }
          end
        end
        it 'updates the classes for all environments' do
          expect { subject.update_classes }.not_to raise_error
          expect(subject.update_classes.status).to eq(201)
        end
        it 'updates the classes for a single environment if specified' do
          expect { subject.update_classes('test_environment') }.not_to raise_error
          response = subject.update_classes('test_environment')
          expect(response.status).to eq(201)
          hashed_query = CGI.parse(response.env.url.query)
          expect(hashed_query).to eq('environment' => ['test_environment'])
        end
      end

      describe '.pin_nodes' do
        it 'works when passed a set of nodes' do
          expect(subject.connection).to receive(:post).with('v1/groups/group_id/pin')
          expect { subject.pin_nodes("group_id", ["node1", "node2"]) }.not_to raise_error
        end
      end

      describe '.unpin_nodes' do
        it 'works when passed a set of nodes' do
          expect(subject.connection).to receive(:post).with('v1/groups/group_id/unpin')
          expect { subject.unpin_nodes("group_id", ["node1", "node2"]) }.not_to raise_error
        end
      end

      describe '.get_list_of_node_groups' do
        before do
          # find the index of the default Faraday::Adapter::NetHttp handler
          # and replace it with the Test adapter
          index = subject.connection.builder.handlers.index(Faraday::Adapter::NetHttp)
          subject.connection.builder.swap(index, Faraday::Adapter::Test) do |stub|
            stub.get('classifier-api/v1/groups') { |env| [200, {}, group_list] }
          end
        end
        it 'returns list of groups' do
          expect { subject.get_list_of_node_groups }.not_to raise_error
          list = subject.get_list_of_node_groups
          expect(list.is_a?(Array)).to be true
        end
      end

      describe '.get_list_of_nodes' do
        before do
          # find the index of the default Faraday::Adapter::NetHttp handler
          # and replace it with the Test adapter
          index = subject.connection.builder.handlers.index(Faraday::Adapter::NetHttp)
          subject.connection.builder.swap(index, Faraday::Adapter::Test) do |stub|
            stub.get('classifier-api/v1/nodes') { |env| [200, {}, node_list] }
          end
        end
        it 'returns list of nodes' do
          expect { subject.get_list_of_nodes }.not_to raise_error
          list = subject.get_list_of_nodes
          expect(list.is_a?(Array)).to be true
        end
      end

      describe '.get_list_of_environments' do
        before do
          # find the index of the default Faraday::Adapter::NetHttp handler
          # and replace it with the Test adapter
          index = subject.connection.builder.handlers.index(Faraday::Adapter::NetHttp)
          subject.connection.builder.swap(index, Faraday::Adapter::Test) do |stub|
            stub.get('classifier-api/v1/environments') { |env| [200, {}, environment_list] }
          end
        end
        it 'returns list of environments' do
          expect { subject.get_list_of_environments }.not_to raise_error
          list = subject.get_list_of_environments
          expect(list.is_a?(Array)).to be true
        end
      end

      describe '.get_list_of_classes' do
        before do
          # find the index of the default Faraday::Adapter::NetHttp handler
          # and replace it with the Test adapter
          index = subject.connection.builder.handlers.index(Faraday::Adapter::NetHttp)
          subject.connection.builder.swap(index, Faraday::Adapter::Test) do |stub|
            stub.get('classifier-api/v1/classes') { |env| [200, {}, class_list] }
          end
        end
        it 'returns list of classes' do
          expect { subject.get_list_of_classes }.not_to raise_error
          list = subject.get_list_of_classes
          expect(list.is_a?(Array)).to be true
        end
      end

      describe '.nodes_match?' do
        before do
          # find the index of the default Faraday::Adapter::NetHttp handler
          # and replace it with the Test adapter
          index = subject.connection.builder.handlers.index(Faraday::Adapter::NetHttp)
          subject.connection.builder.swap(index, Faraday::Adapter::Test) do |stub|
            stub.get('classifier-api/v1/nodes') { |env| [200, {}, node_list] }
          end
        end
        it 'nodes do not match' do
          expect(subject.nodes_match?(node_list.dup.push('another_array_item'))).to be false
        end
        it 'nodes match' do
          expect(subject.nodes_match?(node_list)).to be true
        end

      end

      describe '.groups_match?' do
        before do
          # find the index of the default Faraday::Adapter::NetHttp handler
          # and replace it with the Test adapter
          index = subject.connection.builder.handlers.index(Faraday::Adapter::NetHttp)
          subject.connection.builder.swap(index, Faraday::Adapter::Test) do |stub|
            stub.get('classifier-api/v1/groups') { |env| [200, {}, group_list] }
          end
        end
        it 'groups do not match' do
          expect(subject.groups_match?(group_list.dup.push('another_array_item'))).to be false
        end
        it 'groups match' do
          expect(subject.groups_match?(group_list)).to be true
        end

      end

      describe '.classes_match?' do
        before do
          # find the index of the default Faraday::Adapter::NetHttp handler
          # and replace it with the Test adapter
          index = subject.connection.builder.handlers.index(Faraday::Adapter::NetHttp)
          subject.connection.builder.swap(index, Faraday::Adapter::Test) do |stub|
            stub.get('classifier-api/v1/classes') { |env| [200, {}, class_list] }
          end
        end
        it 'classes do not match' do
          expect(subject.classes_match?(class_list.dup.push('another_array_item'))).to be false
        end
        it 'classes match' do
          expect(subject.classes_match?(class_list)).to be true
        end

      end

      describe '.environments_match?' do
        before do
          # find the index of the default Faraday::Adapter::NetHttp handler
          # and replace it with the Test adapter
          index = subject.connection.builder.handlers.index(Faraday::Adapter::NetHttp)
          subject.connection.builder.swap(index, Faraday::Adapter::Test) do |stub|
            stub.get('classifier-api/v1/environments') { |env| [200, {}, environment_list] }
          end
        end
        it 'environments do not match' do
          expect(subject.environments_match?(environment_list.dup.push('another_array_item'))).to be false
        end
        it 'environments match' do
          expect(subject.environments_match?(environment_list)).to be true
        end

      end

      describe '.classifier_database_matches_self?' do
        before do
          # find the index of the default Faraday::Adapter::NetHttp handler
          # and replace it with the Test adapter
          index = subject.connection.builder.handlers.index(Faraday::Adapter::NetHttp)
          subject.connection.builder.swap(index, Faraday::Adapter::Test) do |stub|
            stub.get('classifier-api/v1/nodes') { |env| env[:url].to_s == "https://test.com:4433/classifier-api/v1/nodes" ?
                [200, [], node_list] :
                [200, [], node_list.dup.push('another_array_item')] }
            stub.get('classifier-api/v1/environments') { |env| env[:url].to_s == "https://test.com:4433/classifier-api/v1/environments" ?
                [200, [], environment_list] :
                [200, [], environment_list.dup.push('another_array_item')] }
            stub.get('classifier-api/v1/groups') { |env| env[:url].to_s == "https://test.com:4433/classifier-api/v1/groups" ?
                [200, [], group_list] :
                [200, [], group_list.dup.push('another_array_item')] }
            stub.get('classifier-api/v1/classes') { |env| env[:url].to_s == "https://test.com:4433/classifier-api/v1/classes" ?
                [200, [], class_list] :
                [200, [], class_list.dup.push('another_array_item')] }
          end

        end
        it 'compare with self' do
          expect { subject.classifier_database_matches_self?('test.com') }.not_to raise_error
        end

        it 'compare with different' do
          expect { subject.classifier_database_matches_self?('test2.com') }.to raise_error /Nodes do not match - other_nodes/
        end
      end
    end
  end
end
