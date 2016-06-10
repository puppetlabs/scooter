require 'spec_helper'

module Scooter

  describe HttpDispatchers::HttpDispatcher do

    let(:host) {double('host')}

    subject { HttpDispatchers::HttpDispatcher.new(host) }


    context 'with a beaker host passed in' do
      unixhost = { roles:     ['test_role'],
                   'platform' => 'debian-7-x86_64' }
      let(:host) { Beaker::Host.create('test.com', unixhost, {}) }

      before do
        expect(Scooter::Utilities::BeakerUtilities).to receive(:pe_ca_cert_file).and_return('cert file')
        expect(Scooter::Utilities::BeakerUtilities).to receive(:pe_private_key_file).and_return('key file')
        expect(Scooter::Utilities::BeakerUtilities).to receive(:pe_hostcert_file).and_return('host cert')
        expect(subject).not_to be_nil

      end

      it 'sets the hostname correctly' do
        expect(subject.connection.url_prefix.hostname).to eq('test.com')
      end

      it 'automatically has been configured for https' do
        expect(subject.connection.url_prefix.scheme).to eq('https')
      end

      it 'automatically has a defined CA file' do
        expect(subject.connection.ssl['ca_file']).to eq('cert file')
      end

      it 'automatically has a defined client key' do
        expect(subject.connection.ssl['client_key']).to eq('key file')
      end

      it 'automatically has a defined client cert' do
        expect(subject.connection.ssl['client_cert']).to eq('host cert')
      end

      it 'has a URI::HTTPS object for a url_prefix' do
        expect(subject.connection.url_prefix).to be_an_instance_of(URI::HTTPS)
      end

      context 'when it receives a 500 error' do
        before do
          index = subject.connection.builder.handlers.index(Faraday::Adapter::Typhoeus)
          subject.connection.builder.swap(index, Faraday::Adapter::Test) do |stub|
            stub.get('/test/route') {[500,
                                      {'content-type' => 'application/json;charset=UTF-8'},
                                      "{ \"key\" : \"value\" }"]}
          end
        end
        it 'has a correctly parsed body in the error' do
          expect{subject.connection.get('/test/route')}.to raise_error do |error|
            expect(error.response[:body]).to be_a(Hash)
          end

        end
      end

      context 'execute_in_parallel' do
        responses = []
        it 'does not get responses until the parallel block has completed' do
          subject.execute_in_parallel(2) do
            responses << subject.connection.get('test/parallel/route')
            expect(responses[0].env).to be_nil
          end
          expect(responses.size).to eq(2)
          # Can't find a really good way to return a meaningful response since the parallel code
          # lives below the post/get/delete methods, so we can't use Faraday::Adapter::Test
          expect(responses[0].status).to eq(0)
        end

      end
    end

    context 'with a string passed in for initialization' do
      let(:host) {'test.com'}
      before do
        expect(subject).not_to be_nil
      end

      it 'sets the hostname correctly for the dispatcher object' do
        expect(subject.connection.url_prefix.host).to eq('test.com')

      end

      it 'does not set ssl when there are no ssl components to add' do
        expect(subject.add_ssl_components_to_connection).to eq(nil)
        expect(subject.connection.url_prefix.scheme).to eq('http')
        expect(subject.connection.ssl['client_key']).to eq(nil)
        expect(subject.connection.ssl['client_cert']).to eq(nil)
        expect(subject.connection.ssl['ca_file']).to eq(nil)
      end
    end

  end

end
