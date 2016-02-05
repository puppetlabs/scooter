require 'spec_helper'

module Scooter

  describe Scooter::HttpDispatchers::Classifier do

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
          expect{subject.update_classes}.not_to raise_error
          expect(subject.update_classes('production').status).to eq(201)
        end
        it 'updates the classes for a single environment if specified' do
          expect{subject.update_classes('test_environment')}.not_to raise_error
          response = subject.update_classes('test_environment')
          expect(response.status).to eq(201)
          hashed_query = CGI.parse(response.env.url.query)
          expect(hashed_query).to eq('environment'=> ['test_environment'])
        end
      end
    end
  end
end
