require "spec_helper"
module Scooter

  describe HttpDispatchers::PuppetdbDispatcher do

    let(:host) {double('host')}
    let(:credentials) {double('credentials')}
    let(:credentials) {{login: 'Ziggy', password: 'Stardust'}}

    subject { HttpDispatchers::PuppetdbDispatcher.new(host) }

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

    context 'with a beaker host passed in' do
      describe '.query_nodes' do
        before do
          # find the index of the default Faraday::Adapter::NetHttp handler
          # and replace it with the Test adapter
          index = subject.connection.builder.handlers.index(Faraday::Adapter::NetHttp)
          subject.connection.builder.swap(index, Faraday::Adapter::Test) do |stub|
            stub.post('/pdb/query/v4/nodes') { [200, []] }
          end
        end
        it 'query for all nodes' do
          expect{subject.query_nodes}.not_to raise_error
          expect(subject.query_nodes.status).to eq(200)
        end
        it 'query for nodes matching query' do
          expect{subject.query_nodes('["and",   ["=", ["fact", "kernel"], "Linux"]]')}.not_to raise_error
          response = subject.query_nodes('["and",   ["=", ["fact", "kernel"], "Linux"]]')
          expect(response.status).to eq(200)
          hashed_query = CGI.parse(response.env.url.query)
          expect(hashed_query).to eq('query'=> ['["and",   ["=", ["fact", "kernel"], "Linux"]]'])
        end
      end
    end
  end
end
