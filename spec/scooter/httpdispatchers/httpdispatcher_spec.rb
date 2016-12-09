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
        expect(OpenSSL::PKey).to receive(:read).and_return('Pkey')
        expect(OpenSSL::X509::Certificate).to receive(:new).and_return('client_cert')
        allow_any_instance_of(HttpDispatchers::HttpDispatcher).to receive(:get_host_cert) {'host cert'}
        allow_any_instance_of(HttpDispatchers::HttpDispatcher).to receive(:get_host_private_key) {'key file'}
        allow_any_instance_of(HttpDispatchers::HttpDispatcher).to receive(:get_host_cacert) {'cert file'}
        expect(subject).to be_kind_of(HttpDispatchers::HttpDispatcher)
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
        expect(subject.connection.ssl['client_key']).to eq('Pkey')
      end

      it 'automatically has a defined client cert' do
        expect(subject.connection.ssl['client_cert']).to eq('client_cert')
      end

      it 'has a URI::HTTPS object for a url_prefix' do
        expect(subject.connection.url_prefix).to be_an_instance_of(URI::HTTPS)
      end

      context 'when it receives a 500 error' do
        before do
          allow_any_instance_of(Beaker::Http::FaradayBeakerLogger).to receive(:info) { true }
          allow_any_instance_of(Beaker::Http::FaradayBeakerLogger).to receive(:debug) { true }
          index = subject.connection.builder.handlers.index(Faraday::Adapter::NetHttp)
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
    end
  end
end
