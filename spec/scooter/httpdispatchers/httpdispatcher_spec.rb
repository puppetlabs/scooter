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
        expect(Scooter::Utilities::BeakerUtilities).to receive(:pe_private_key).and_return('key file')
        expect(Scooter::Utilities::BeakerUtilities).to receive(:pe_hostcert).and_return('host cert')
        expect(OpenSSL::PKey).to receive(:read).and_return('Pkey')
        expect(OpenSSL::X509::Certificate).to receive(:new).and_return('client_cert')
        expect(Scooter::Utilities::BeakerUtilities).to receive(:get_public_ip).and_return('public_ip')
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
        expect(subject.connection.ssl['client_key']).to eq('Pkey')
      end

      it 'automatically has a defined client cert' do
        expect(subject.connection.ssl['client_cert']).to eq('client_cert')
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
