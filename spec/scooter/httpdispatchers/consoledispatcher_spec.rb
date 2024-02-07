require 'spec_helper'

module Scooter

  describe HttpDispatchers::ConsoleDispatcher do

    let(:host) {double('host')}
    let(:credentials) { { login: username, password: password} }
    let(:username) {'Ziggy'}
    let(:password) {'Stardust'}
    let(:mock_page) {double('mock_page')}
    let(:logger) { double('logger')}

    subject { HttpDispatchers::ConsoleDispatcher.new(host, credentials) }

    context 'with a beaker host passed in' do
      unixhost = { roles:     ['test_role'],
                   'platform' => 'debian-7-x86_64' }
      let(:host) { Beaker::Host.create('test.com', unixhost, {:logger => logger}) }
      before do
        allow(logger).to receive(:info) {true}
        allow(logger).to receive(:debug) {true}
        expect(OpenSSL::PKey).not_to receive(:read)
        expect(OpenSSL::X509::Certificate).not_to receive(:new)
        allow_any_instance_of(HttpDispatchers::ConsoleDispatcher).to receive(:configure_cacert_with_puppet).and_return('cacert')
        expect(subject).to be_kind_of(HttpDispatchers::ConsoleDispatcher)
      end

      context '"signin with a page that returns a token' do
        before do
          stub_request(:get, /auth\/login/).
            to_return(status: 200,
                      body: '',
                      headers: {
                        "set-cookie"=>"__HOST-somecookie=something;Secure;Path=/",
                      })
          stub_request(:post, /auth\/login/).
            to_return(status: 200,
                      body: '',
                      headers: {"server"=>"nginx/1.8.1",
                                "date"=>"Tue, 29 Nov 2016 22:05:41 GMT",
                                "content-length"=>"0",
                                "connection"=>"close",
                                "set-cookie"=>"__HOST-pl_ssti=0CeHhpz5PPLna7kpaEMcTHjJ62z9eizHTzsxEXNK8W20;Secure;Path=/",
                                "location"=>"/",
                                "x-frame-options"=>"DENY"})

          stub_request(:get, 'https://test.com/').
            to_return(status: 200, body: '', headers: {})
        end

        it 'sends the credentials' do
          expect{subject.signin}.to_not raise_error
        end

        it 'sets the token in the header' do
          subject.signin
          expect(subject.connection.headers['Cookie']).to include('pl_ssti=')
        end
      end
    end
  end
end
