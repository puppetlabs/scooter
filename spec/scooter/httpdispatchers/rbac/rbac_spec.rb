require 'spec_helper'

module Scooter

  describe Scooter::HttpDispatchers::Rbac do

    let(:host) {double('host')}
    let(:credentials) {double('credentials')}

    subject { HttpDispatchers::ConsoleDispatcher.new(host, credentials) }

    context 'with a beaker host passed in' do

      unixhost = { roles:     ['test_role'],
                   'platform' => 'debian-7-x86_64' }
      let(:host) { Beaker::Host.create('test.com', unixhost, {}) }
      let(:credentials) {{login: 'Ziggy', password: 'Stardust'}}

      before do
        expect(Scooter::Utilities::BeakerUtilities).to receive(:pe_ca_cert_file).and_return('cert file')
        expect(subject).not_to be_nil
      end

      describe '.acquire_token_with_credentials' do
        before do
          # find the index of the default Faraday::Adapter::NetHttp handler
          # and replace it with the Test adapter
          index = subject.connection.builder.handlers.index(Faraday::Adapter::Typhoeus)
          subject.connection.builder.swap(index, Faraday::Adapter::Test) do |stub|
            stub.post('/rbac-api/v1/auth/token') { [200, {}, 'token' =>'blah'] }
            end
        end
        it 'sets the token instance variable for the dispatcher' do
          expect{subject.acquire_token_with_credentials}.not_to raise_error
          expect(subject.token).to eq('blah')
        end
        it 'accepts an optional lifetime parameter' do
          expect{subject.acquire_token_with_credentials('600')}.not_to raise_error
          expect(subject.token).to eq('blah')
        end
      end

      describe 'ensure failure to get a token does not set the token instance variable' do
        before do
          # find the index of the default Faraday::Adapter::NetHttp handler
          # and replace it with the Test adapter
          index = subject.connection.builder.handlers.index(Faraday::Adapter::Typhoeus)
          subject.connection.builder.swap(index, Faraday::Adapter::Test) do |stub|
            stub.post('/rbac-api/v1/auth/token') { [401, {}, 'unauthorized'] }
          end
        end
        it 'the token variable should still be nil for a failed request' do
          expect{subject.acquire_token_with_credentials}.to raise_error(Faraday::ClientError)
          expect(subject.token).to eq(nil)
        end
      end

      describe '.get_group_data_by_name' do
        let(:groups_array) {
          [{"user_ids"=>[],
            "role_ids"=>[],
            "display_name"=>"",
            "is_superuser"=>false,
            "is_remote"=>true,
            "is_group"=>true,
            "login"=>"group1",
            "id"=>"09c2c1fd-ea01-4555-bc7b-a8f25c4511f8"},
           {"user_ids"=>[],
             "role_ids"=>[],
             "display_name"=>"",
             "is_superuser"=>false,
             "is_remote"=>true,
             "is_group"=>true,
             "login"=>"group2",
             "id"=>"09c2c1fd-ea01-4555-bc7b-a8f25c4511f7"}]
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
    end
  end
end
