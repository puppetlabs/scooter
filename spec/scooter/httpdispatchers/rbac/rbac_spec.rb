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
        expect(Scooter::Utilities::BeakerUtilities).to receive(:get_public_ip).and_return('public_ip')
        expect(subject).not_to be_nil
      end

      describe '.acquire_token_with_credentials' do
        before do
          # find the index of the default Faraday::Adapter::NetHttp handler
          # and replace it with the Test adapter
          index = subject.connection.builder.handlers.index(Faraday::Adapter::NetHttp)
          subject.connection.builder.swap(index, Faraday::Adapter::Test) do |stub|
            stub.post('/rbac-api/v1/auth/token') { [200, {}, 'token' =>'blah'] }
            end
        end
        it 'sets the token instance variable for the dispatcher' do
          expect{subject.acquire_token_with_credentials}.not_to raise_error
          expect(subject.token).to eq('blah')
        end
      end

      describe 'ensure failure to get a token does not set the token instance variable' do
        before do
          # find the index of the default Faraday::Adapter::NetHttp handler
          # and replace it with the Test adapter
          index = subject.connection.builder.handlers.index(Faraday::Adapter::NetHttp)
          subject.connection.builder.swap(index, Faraday::Adapter::Test) do |stub|
            stub.post('/rbac-api/v1/auth/token') { [401, {}, 'unauthorized'] }
          end
        end
        it 'the token variable should still be nil for a failed request' do
          expect{subject.acquire_token_with_credentials}.to raise_error(Faraday::ClientError)
          expect(subject.token).to eq(nil)
        end
      end

    end
  end
end
