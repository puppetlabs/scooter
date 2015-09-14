require 'spec_helper'

describe Scooter::HttpDispatchers::CodeManager do

  let(:api) {
    class DummyClass
      attr_accessor :connection
    end

    dummy = DummyClass.new.extend(Scooter::HttpDispatchers::CodeManager)
    dummy.connection = double(Faraday::Connection)
    dummy
  }
  let(:array) { ['environment one', 'environment two'] }

  describe '.deploy_environments' do

    it 'works when passing in an array' do
      expect(api.connection).to receive_message_chain('url_prefix.port=').with(8170)
      expect(api.connection).to receive(:post).with('/code-manager/v1/deploys')
      expect{api.deploy_environments(array)}.not_to raise_error
    end

    context 'negative cases' do

      it 'should fail with no arguements' do
        expect{api.deploy_environments}.to raise_error(ArgumentError)
      end
    end
  end

  describe '.deploy_all_environments' do

    it 'works with no token' do
      expect(api.connection).to receive_message_chain('url_prefix.port=').with(8170)
      expect(api.connection).to receive(:post).with('/code-manager/v1/deploys')
      expect{api.deploy_all_environments}.not_to raise_error
    end

    it 'works when supplied a token' do
      expect(api.connection).to receive_message_chain('url_prefix.port=').with(8170)
      expect(api.connection).to receive(:post).with('/code-manager/v1/deploys?token=this_is_my_token')
      expect{api.deploy_all_environments('this_is_my_token')}.not_to raise_error
    end
  end
end
