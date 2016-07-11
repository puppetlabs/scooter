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

      describe '.query_catalogs' do
        before do
          # find the index of the default Faraday::Adapter::NetHttp handler
          # and replace it with the Test adapter
          index = subject.connection.builder.handlers.index(Faraday::Adapter::NetHttp)
          subject.connection.builder.swap(index, Faraday::Adapter::Test) do |stub|
            stub.post('/pdb/query/v4/catalogs') { [200, []] }
          end
        end
        it 'query for all catalogs' do
          expect{subject.query_catalogs}.not_to raise_error
          expect(subject.query_catalogs.status).to eq(200)
        end
        it 'query for catalogs matching query' do
          expect{subject.query_catalogs('[">","producer_timestamp","2015-11-19"]')}.not_to raise_error
          response = subject.query_catalogs('[">","producer_timestamp","2015-11-19"]')
          expect(response.status).to eq(200)
          hashed_query = CGI.parse(response.env.url.query)
          expect(hashed_query).to eq('query'=> ['[">","producer_timestamp","2015-11-19"]'])
        end
      end

      describe '.query_reports' do
        before do
          # find the index of the default Faraday::Adapter::NetHttp handler
          # and replace it with the Test adapter
          index = subject.connection.builder.handlers.index(Faraday::Adapter::NetHttp)
          subject.connection.builder.swap(index, Faraday::Adapter::Test) do |stub|
            stub.post('/pdb/query/v4/reports') { [200, []] }
          end
        end
        it 'query for all reports' do
          expect{subject.query_reports}.not_to raise_error
          expect(subject.query_reports.status).to eq(200)
        end
        it 'query for reports matching query' do
          expect{subject.query_reports('["extract",[["function","count"], "status"], ["~","certname",""], ["group_by", "status"]]')}.not_to raise_error
          response = subject.query_reports('["extract",[["function","count"], "status"], ["~","certname",""], ["group_by", "status"]]')
          expect(response.status).to eq(200)
          hashed_query = CGI.parse(response.env.url.query)
          expect(hashed_query).to eq('query'=> ['["extract",[["function","count"], "status"], ["~","certname",""], ["group_by", "status"]]'])
        end
      end

      describe '.query_facts' do
        before do
          # find the index of the default Faraday::Adapter::NetHttp handler
          # and replace it with the Test adapter
          index = subject.connection.builder.handlers.index(Faraday::Adapter::NetHttp)
          subject.connection.builder.swap(index, Faraday::Adapter::Test) do |stub|
            stub.post('/pdb/query/v4/facts') { [200, []] }
          end
        end
        it 'query for all facts' do
          expect{subject.query_facts}.not_to raise_error
          expect(subject.query_facts.status).to eq(200)
        end
        it 'query for facts matching query' do
          expect{subject.query_facts('["=", "name", "operatingsystem"]')}.not_to raise_error
          response = subject.query_facts('["=", "name", "operatingsystem"]')
          expect(response.status).to eq(200)
          hashed_query = CGI.parse(response.env.url.query)
          expect(hashed_query).to eq('query'=> ['["=", "name", "operatingsystem"]'])
        end
      end

      describe '.nodes_match?' do
        before do
          # find the index of the default Faraday::Adapter::NetHttp handler
          # and replace it with the Test adapter
          index = subject.connection.builder.handlers.index(Faraday::Adapter::NetHttp)
          subject.connection.builder.swap(index, Faraday::Adapter::Test) do |stub|
            stub.post('/pdb/query/v4/nodes') { [200, [], [{'certname' => 'name', 'facts_timestamp' => 'facts_time', 'report_timestamp' => 'reports_time', 'catalog_timestamp' => 'catalog_time'}]] }
          end
        end
        it 'nodes different size' do
          expect(subject.nodes_match?([{'certname' => 'name', 'facts_timestamp' => 'facts_time', 'report_timestamp' => 'reports_time', 'catalog_timestamp' => 'catalog_time'},
                                       {'certname' => 'name2', 'facts_timestamp' => 'facts_time', 'report_timestamp' => 'reports_time', 'catalog_timestamp' => 'catalog_time'}])).to be false
        end
        it 'nodes do not match' do
          expect(subject.nodes_match?([{'certname' => 'name_bad', 'facts_timestamp' => 'facts_time', 'report_timestamp' => 'reports_time', 'catalog_timestamp' => 'catalog_time'}])).to be false
          expect(subject.nodes_match?([{'certname' => 'name', 'facts_timestamp' => 'facts_time_bad', 'report_timestamp' => 'reports_time', 'catalog_timestamp' => 'catalog_time'}])).to be false
          expect(subject.nodes_match?([{'certname' => 'name', 'facts_timestamp' => 'facts_time', 'report_timestamp' => 'reports_time_bad', 'catalog_timestamp' => 'catalog_time'}])).to be false
          expect(subject.nodes_match?([{'certname' => 'name', 'facts_timestamp' => 'facts_time', 'report_timestamp' => 'reports_time', 'catalog_timestamp' => 'catalog_time_bad'}])).to be false
        end
        it 'nodes match' do
          expect(subject.nodes_match?([{'certname' => 'name', 'facts_timestamp' => 'facts_time', 'report_timestamp' => 'reports_time', 'catalog_timestamp' => 'catalog_time'}])).to be true
        end

      end

      describe '.catalogs_match?' do
        before do
          # find the index of the default Faraday::Adapter::NetHttp handler
          # and replace it with the Test adapter
          index = subject.connection.builder.handlers.index(Faraday::Adapter::NetHttp)
          subject.connection.builder.swap(index, Faraday::Adapter::Test) do |stub|
            stub.post('/pdb/query/v4/catalogs') { [200, [], [{'catalog_uuid' => 'catalog_uuid_1', 'producer_timestamp' => 'time'}]] }
          end
        end
        it 'catalogs different size' do
          expect(subject.catalogs_match?([{'catalog_uuid' => 'catalog_uuid_1', 'producer_timestamp' => 'time'},
                                         {'catalog_uuid' => 'catalog_uuid_2', 'producer_timestamp' => 'time2'}])).to be false
        end
        it 'catalogs do not match' do
          expect(subject.catalogs_match?([{'catalog_uuid' => 'catalog_uuid_2', 'producer_timestamp' => 'time2'}])).to be false
        end
        it 'catalogs match' do
          expect(subject.catalogs_match?([{'catalog_uuid' => 'catalog_uuid_1', 'producer_timestamp' => 'time'}])).to be true
        end

      end

      describe '.facts_match?' do
        before do
          # find the index of the default Faraday::Adapter::NetHttp handler
          # and replace it with the Test adapter
          index = subject.connection.builder.handlers.index(Faraday::Adapter::NetHttp)
          subject.connection.builder.swap(index, Faraday::Adapter::Test) do |stub|
            stub.post('/pdb/query/v4/facts') { [200, [], [{'name' => 'name', 'value' => 'value'}]] }
          end
        end
        it 'facts different size' do
          expect(subject.facts_match?([{'name' => 'name', 'value' => 'value'},
                                       {'name2' => 'name', 'value2' => 'value'}])).to be false
        end
        it 'facts do not match' do
          expect(subject.facts_match?([{'name2' => 'name', 'value2' => 'value'}])).to be false
        end
        it 'facts match' do
          expect(subject.facts_match?([{'name' => 'name', 'value' => 'value'}])).to be true
        end

      end

      describe '.reports_match?' do
        before do
          # find the index of the default Faraday::Adapter::NetHttp handler
          # and replace it with the Test adapter
          index = subject.connection.builder.handlers.index(Faraday::Adapter::NetHttp)
          subject.connection.builder.swap(index, Faraday::Adapter::Test) do |stub|
            stub.post('/pdb/query/v4/reports') { [200, [], [{'hash' => 'hash_value', 'producer_timestamp' => 'time'}]] }
          end
        end
        it 'reports different size' do
          expect(subject.reports_match?([{'hash' => 'hash_value', 'producer_timestamp' => 'time'},
                                       {'hash' => 'hash_value2', 'producer_timestamp' => 'time2'}])).to be false
        end
        it 'reports do not match' do
          expect(subject.reports_match?([{'hash' => 'hash_value2', 'producer_timestamp' => 'time2'}])).to be false
        end
        it 'reports match' do
          expect(subject.reports_match?([{'hash' => 'hash_value', 'producer_timestamp' => 'time'}])).to be true
        end

      end

      describe '.database_matches_self?' do
        before do
          # find the index of the default Faraday::Adapter::NetHttp handler
          # and replace it with the Test adapter
          index = subject.connection.builder.handlers.index(Faraday::Adapter::NetHttp)
          subject.connection.builder.swap(index, Faraday::Adapter::Test) do |stub|
            stub.post('/pdb/query/v4/nodes') { |env| env[:url].to_s == "https://test.com:8081/pdb/query/v4/nodes" ?
                [200, [], [{'certname' => 'name', 'facts_timestamp' => 'facts_time', 'report_timestamp' => 'reports_time', 'catalog_timestamp' => 'catalog_time'}]] :
                [200, [], [{'certname' => 'name2', 'facts_timestamp' => 'facts_time', 'report_timestamp2' => 'reports_time', 'catalog_timestamp' => 'catalog_time2'}]] }
            stub.post('/pdb/query/v4/catalogs') { |env| env[:url].to_s == "https://test.com:8081/pdb/query/v4/catalogs" ?
                [200, [], [{'catalog_uuid' => 'catalog_uuid_1', 'producer_timestamp' => 'time'}]] :
                [200, [], [{'catalog_uuid' => 'catalog_uuid_2', 'producer_timestamp' => 'time2'}]] }
            stub.post('/pdb/query/v4/facts') { |env| env[:url].to_s == "https://test.com:8081/pdb/query/v4/facts" ?
                [200, [], [{'name' => 'name', 'value' => 'value'}]] :
                [200, [], [{'name' => 'name2', 'value' => 'value2'}]] }
            stub.post('/pdb/query/v4/reports') { |env| env[:url].to_s == "https://test.com:8081/pdb/query/v4/reports" ?
                [200, [], [{'hash' => 'hash_value', 'producer_timestamp' => 'time'}]] :
                [200, [], [{'hash' => 'hash_value2', 'producer_timestamp' => 'time2'}]] }
          end

        end
        it 'compare with self' do
          expect(subject.database_matches_self?('test.com')).to be_truthy
        end

        it 'compare with different' do
          expect(subject.faraday_logger).to receive(:warn).with /Nodes do not match/
          expect(subject.database_matches_self?('test2.com')).to be_falsey
        end
      end

    end
  end
end
