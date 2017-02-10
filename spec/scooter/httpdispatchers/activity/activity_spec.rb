require 'spec_helper'

module Scooter

  describe Scooter::HttpDispatchers::Activity do

    let(:host) { double('host') }
    let(:credentials) { double('credentials') }
    let(:classifier_events) {
      {
          "commits" => [
              {
                  "object"    => {
                      "id"   => "da180809-36b1-4049-ab7b-29188dd6e255",
                      "name" => "Agent-specified environment"
                  },
                  "subject"   => {
                      "id"   => "af94921f-bd76-4b58-b5ce-e17c029a2790",
                      "name" => "api_user"
                  },
                  "timestamp" => "2016-06-09T18:08:13Z",
                  "events"    => [
                      {
                          "message" => "Changed the environment override setting to true"
                      },
                      {
                          "message" => "Changed the environment to \"agent-specified\""
                      },
                      {
                          "message" => "Changed the parent to 395ad98e-c536-4dfc-9f5f-b00d5ee2454f"
                      },
                      {
                          "message" => "Created the \"Agent-specified environment\" group with id da180809-36b1-4049-ab7b-29188dd6e255"
                      }
                  ]
              },
              {
                  "object"    => {
                      "id"   => "395ad98e-c536-4dfc-9f5f-b00d5ee2454f",
                      "name" => "Production environment"
                  },
                  "subject"   => {
                      "id"   => "af94921f-bd76-4b58-b5ce-e17c029a2790",
                      "name" => "api_user"
                  },
                  "timestamp" => "2016-06-09T18:08:13Z",
                  "events"    => [
                      {
                          "message" => "Changed the environment override setting to true"
                      },
                      {
                          "message" => "Changed the environment to \"production\""
                      },
                      {
                          "message" => "Changed the parent to 00000000-0000-4000-8000-000000000000"
                      },
                      {
                          "message" => "Changed the rule to [\"and\" [\"~\" \"name\" \".*\"]]"
                      },
                      {
                          "message" => "Created the \"Production environment\" group with id 395ad98e-c536-4dfc-9f5f-b00d5ee2454f"
                      }
                  ]
              }
          ]
      }
    }
    let(:rbac_events) {
      {
          "commits"    => [
              {
                  "object"    => {
                      "id"   => "42bf351c-f9ec-40af-84ad-e976fec7f4bd",
                      "name" => "admin"
                  },
                  "subject"   => {
                      "id"   => "42bf351c-f9ec-40af-84ad-e976fec7f4bd",
                      "name" => "admin"
                  },
                  "timestamp" => "2016-06-09T19:14:26Z",
                  "events"    => [
                      {
                          "message" => "User Administrator (42bf351c-f9ec-40af-84ad-e976fec7f4bd) logged in."
                      }
                  ]
              },
              {
                  "object"    => {
                      "id"   => "42bf351c-f9ec-40af-84ad-e976fec7f4bd",
                      "name" => "admin"
                  },
                  "subject"   => {
                      "id"   => "42bf351c-f9ec-40af-84ad-e976fec7f4bd",
                      "name" => "admin"
                  },
                  "timestamp" => "2016-06-09T18:08:14Z",
                  "events"    => [
                      {
                          "message" => "Password reset for user Administrator (42bf351c-f9ec-40af-84ad-e976fec7f4bd)."
                      }
                  ]
              },
              {
                  "object"    => {
                      "id"   => "42bf351c-f9ec-40af-84ad-e976fec7f4bd",
                      "name" => "admin"
                  },
                  "subject"   => {
                      "id"   => "af94921f-bd76-4b58-b5ce-e17c029a2790",
                      "name" => "api_user"
                  },
                  "timestamp" => "2016-06-09T18:08:14Z",
                  "events"    => [
                      {
                          "message" => "A password reset token was generated for user Administrator (42bf351c-f9ec-40af-84ad-e976fec7f4bd)."
                      }
                  ]
              }
          ],
          "offset"     => 0,
          "limit"      => 3,
          "total-rows" => 3
      }
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

      describe '.get_classifier_events' do
        before do
          # find the index of the default Faraday::Adapter::NetHttp handler
          # and replace it with the Test adapter
          index = subject.connection.builder.handlers.index(Faraday::Adapter::NetHttp)
          subject.connection.builder.swap(index, Faraday::Adapter::Test) do |stub|
            stub.get('activity-api/v1/events?service_id=classifier') { [200, {}] }
          end
        end
        it 'gets classifier events' do
          expect { subject.get_classifier_events }.not_to raise_error
          response = subject.get_classifier_events
          expect(response.status).to eq(200)
          hashed_query = CGI.parse(response.env.url.query)
          expect(hashed_query).to eq('service_id' => ['classifier'])
        end
        it 'appends additional query string parameters' do
          expect { subject.get_classifier_events }.not_to raise_error
          response     = subject.get_classifier_events({ 'subject_type' => 'users', 'subject_id' => 'dfgdfc145-545dfg54f-fdg45s5s' })
          hashed_query = CGI.parse(response.env.url.query)
          expect(hashed_query).to eq({ 'service_id' => ['classifier'], 'subject_type' => ['users'], 'subject_id' => ['dfgdfc145-545dfg54f-fdg45s5s'] })
        end
      end

      describe '.get_rbac_events' do
        before do
          # find the index of the default Faraday::Adapter::NetHttp handler
          # and replace it with the Test adapter
          index = subject.connection.builder.handlers.index(Faraday::Adapter::NetHttp)
          subject.connection.builder.swap(index, Faraday::Adapter::Test) do |stub|
            stub.get('activity-api/v1/events?service_id=rbac') { [200, {}] }
          end
        end
        it 'gets rbac events' do
          expect { subject.get_rbac_events }.not_to raise_error
          response = subject.get_rbac_events
          expect(response.status).to eq(200)
          hashed_query = CGI.parse(response.env.url.query)
          expect(hashed_query).to eq('service_id' => ['rbac'])
        end
        it 'appends additional query string parameters' do
          expect { subject.get_rbac_events }.not_to raise_error
          response = subject.get_rbac_events({ 'subject_type' => 'users', 'subject_id' => 'dfgdfc145-545dfg54f-fdg45s5s' })
          expect(response.status).to eq(200)
          hashed_query = CGI.parse(response.env.url.query)
          expect(hashed_query).to eq({ 'service_id' => ['rbac'], 'subject_type' => ['users'], 'subject_id' => ['dfgdfc145-545dfg54f-fdg45s5s'] })
        end
      end

      describe '.activity_database_matches_self?' do
        before do
          # find the index of the default Faraday::Adapter::NetHttp handler
          # and replace it with the Test adapter
          index = subject.connection.builder.handlers.index(Faraday::Adapter::NetHttp)
          subject.connection.builder.swap(index, Faraday::Adapter::Test) do |stub|
            stub.get('activity-api/v1/events?service_id=rbac') { |env| env[:url].to_s == "https://test.com:4433/activity-api/v1/events?service_id=rbac" ?
                [200, [], rbac_events] :
                [200, [], rbac_events['commits'].dup.push('another_array_item')] }
            stub.get('activity-api/v1/events?service_id=classifier') { |env| env[:url].to_s == "https://test.com:4433/activity-api/v1/events?service_id=classifier" ?
                [200, [], classifier_events] :
                [200, [], classifier_events.dup["commits"].push('another_array_item')] }
          end
          expect(subject).to receive(:is_resolvable).exactly(4).times.and_return(true)
          # expect(subject).to receive(:create_default_connection).with(any_args).twice.and_return(subject.connection)
          # expect(Scooter::Utilities::BeakerUtilities).to receive(:get_public_ip).and_return('public_ip')
        end

        it 'compare with self' do
          expect(subject.activity_database_matches_self?(host)).to be_truthy
        end

        it 'compare with different' do
          expect(subject.host.logger).to receive(:warn).with /Rbac events do not match/
          expect(subject.activity_database_matches_self?(host2)).to be_falsey
        end
      end
    end
  end
end
