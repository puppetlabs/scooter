require 'spec_helper'

describe Faraday::RbacAuthToken do

  let(:conn) { Faraday.new(:url => 'http://test.com/path') }
  let(:dispatcher) { double('dispatcher') }

  before do
    conn.builder.insert(0, Faraday::RbacAuthToken, dispatcher)
    conn.adapter :test do |stub|
      stub.get('/path') {[200, {}, 'success']}
    end
  end

  describe 'a dispatcher with no token' do
    before do
      allow(dispatcher).to receive(:token) { nil }
      allow(dispatcher).to receive(:send_auth_token_as_query_param) { nil }
    end
    it 'sends the request without a token' do
      expect(conn.get.env.url.query).to eq(nil)
      expect(conn.get.env.request_headers['X-Authentication']).to eq(nil)
      expect{conn.get}.not_to raise_error
    end
  end

  describe 'a dispatcher with a token' do
    before do
      allow(dispatcher).to receive(:token) {'testingtoken'}
      allow(dispatcher).to receive(:send_auth_token_as_query_param) { nil }
    end
    it 'sends the request with the token in an X-Authentication header' do
      expect(conn.get.env.request_headers['X-Authentication']).to eq('testingtoken')
    end
  end

  describe 'a dispatcher with a token as a query param' do
    before do
      allow(dispatcher).to receive(:token) { 'testingtoken' }
      allow(dispatcher).to receive(:send_auth_token_as_query_param) { true }
    end
    it 'sends the request with the token as a query param' do
      expect(conn.get.env.url.query).to eq('token=testingtoken')
    end
  end

  describe 'a dispatcher with a token to be sent as a query param does not overwrite other params' do
    before do
      allow(dispatcher).to receive(:token) { 'testingtoken' }
      allow(dispatcher).to receive(:send_auth_token_as_query_param) { true }
    end
    it 'sends the request with the token and other parameters' do
      response = conn.get {|req| req.params[:extra_param] = 'extra_value'}
      hashed_query = CGI.parse(response.env.url.query)
      expect(hashed_query).to eq('token'=> ['testingtoken'], 'extra_param' => ['extra_value'])
    end
  end
end
