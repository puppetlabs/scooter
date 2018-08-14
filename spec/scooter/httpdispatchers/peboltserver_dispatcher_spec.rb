require 'spec_helper'

describe Scooter::HttpDispatchers::PEBoltServerDispatcher do

  let(:pe_bolt_server_api) { Scooter::HttpDispatchers::PEBoltServerDispatcher.new(host) }
  let(:logger) { double('logger')}
  let(:task) {
    {
      "target": {
        "host": "", 
        "user": "bolt",
        "password": "bolt",
        "host-key-check": "false"
      },  
      "task": {
        "metadata": {
          "description": "Echo a message",
          "parameters": {
            "message": "Default string"
          },  
          "file_content": "IyEvdXNyL2Jpbi9lbnYgYmFzaAplY2hvICRQVF9tZXNzYWdlCg=="
        }   
      },  
      "parameters": {
        "message": "Hello world"
      }
    }
  }

  unixhost = { roles:     ['test_role'],
               platform: 'debian-9-x86_64' }
  let(:host) { Beaker::Host.create('test.com', unixhost, {:logger => logger}) }

  subject { pe_bolt_server_api }

  before do
    expect(OpenSSL::PKey).to receive(:read).and_return('Pkey')
    expect(OpenSSL::X509::Certificate).to receive(:new).and_return('client_cert')
    allow_any_instance_of(Scooter::HttpDispatchers::PEBoltServerDispatcher).to receive(:get_host_cert) {'host cert'}
    allow_any_instance_of(Scooter::HttpDispatchers::PEBoltServerDispatcher).to receive(:get_host_private_key) {'key file'}
    allow_any_instance_of(Scooter::HttpDispatchers::PEBoltServerDispatcher).to receive(:get_host_cacert) {'cert file'}
    expect(subject).to be_kind_of(Scooter::HttpDispatchers::PEBoltServerDispatcher)
    allow_any_instance_of(Beaker::Http::FaradayBeakerLogger).to receive(:debug) {true}
    allow_any_instance_of(Beaker::Http::FaradayBeakerLogger).to receive(:info) {true}
  end

  it 'should make requests on the correct port' do
    expect(pe_bolt_server_api.connection.url_prefix.port).to be(8144)
  end

  describe '.ssh_run_task' do

    it { is_expected.to respond_to(:ssh_run_task).with(1).arguments }

    it 'should take a job_id' do
      expect(pe_bolt_server_api.connection).to receive(:post).with("ssh/run_task")
      expect{ pe_bolt_server_api.ssh_run_task(task) }.not_to raise_error
    end
  end
end
