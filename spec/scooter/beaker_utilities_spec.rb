require 'spec_helper'

module Scooter

  describe Utilities::BeakerUtilities do

    let(:result)          { instance_double(Beaker::Result)}
    let(:master)          { instance_double(Beaker::Host) }

    context 'with correct argument' do

      it 'gets the pe ca certfile' do
        cmd = "cat `puppet agent --configprint localcacert`"
        expect_any_instance_of(Beaker::DSL).to receive(:on).with(master, cmd, any_args).and_return(result)
        expect(result).to receive(:stdout).and_return('foobar')
        expect(subject.pe_ca_cert_file(master)).to match(/\/.*pe_certs.*\/cacert.pem/)
      end

      it 'gets the pe hostprivkey' do
        cmd = "cat `puppet agent --configprint hostprivkey`"
        expect_any_instance_of(Beaker::DSL).to receive(:on).with(master, cmd, any_args).and_return(result)
        expect(result).to receive(:stdout).and_return('foobar')
        expect(subject.pe_private_key(master)).to eq('foobar')
      end

      it 'gets the pe hostcert' do
        cmd = "cat `puppet agent --configprint hostcert`"
        expect_any_instance_of(Beaker::DSL).to receive(:on).with(master, cmd, any_args).and_return(result)
        expect(result).to receive(:stdout).and_return('foobar')
        expect(subject.pe_hostcert(master)).to eq('foobar')
      end

    end

    context 'without correct arguments' do

      it 'getting the pe ca certificate fails with no arguments' do
        expect{ subject.pe_ca_cert_file }.to raise_error(ArgumentError)
      end

      it 'getting the pe hostprivkey fails with no arguments' do
        expect{ subject.pe_private_key }.to raise_error(ArgumentError)
      end

      it 'getting the pe hostcert fails with no arguments' do
        expect{ subject.pe_hostcert }.to raise_error(ArgumentError)
      end

    end

  end

end
