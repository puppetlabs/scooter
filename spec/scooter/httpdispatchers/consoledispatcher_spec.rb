require 'spec_helper'

module Scooter

  describe HttpDispatchers::ConsoleDispatcher do

    let(:host) {double('host')}
    let(:credentials) { { login: username, password: password} }
    let(:username) {'Ziggy'}
    let(:password) {'Stardust'}
    let(:mock_page) {double('mock_page')}

    subject { HttpDispatchers::ConsoleDispatcher.new(host, credentials) }

    context 'with a beaker host passed in' do
      unixhost = { roles:     ['test_role'],
                   'platform' => 'debian-7-x86_64' }
      let(:host) { Beaker::Host.create('test.com', unixhost, {}) }
      before do
        expect(Scooter::Utilities::BeakerUtilities).to receive(:pe_ca_cert_file).and_return('cert file')
        expect(subject).not_to be_nil
      end

      context '.signin with a page that returns an xcsrf token' do
        let(:mock_page) { <<-XCSRF_PAGE
            <!doctype html>
              <head>
                <meta name="__anti-forgery-token" content="xcsrf-token" />
              </head>
            </html>
        XCSRF_PAGE
        }
        before do
          index = subject.connection.builder.handlers.index(Faraday::Adapter::Typhoeus)
          subject.connection.builder.swap(index, Faraday::Adapter::Test) do |stub|
            stub.post('/auth/login', "username=#{username}&password=#{password}") {[200, {}, '']}
            stub.get('/') {[200, {}, mock_page]}
          end
        end

        it 'sends the credentials' do
          expect{subject.signin}.to_not raise_error
        end

        it 'sets the xcsrf token in the header' do
          subject.signin
          expect(subject.connection.headers['X-CSRF-Token']).to eq('xcsrf-token')
        end
      end

      context '.signin with a page that has no xcsrf token' do
        let(:mock_page) { <<-XCSRF_PAGE
            <!doctype html>
              <head>
              </head>
            </html>
        XCSRF_PAGE
        }
        before do
          index = subject.connection.builder.handlers.index(Faraday::Adapter::Typhoeus)
          subject.connection.builder.swap(index, Faraday::Adapter::Test) do |stub|
            stub.post('/auth/login', "username=#{username}&password=#{password}") {[200, {}, '']}
            stub.get('/') {[200, {}, mock_page]}
          end
        end

        it 'does not raise an error' do
          expect{subject.signin}.to_not raise_error
        end

        it 'There is no xcsrf token set' do
          subject.signin
          expect(subject.connection.headers['X-CSRF-Token']).to eq(nil)
        end
      end
    end
  end
end

