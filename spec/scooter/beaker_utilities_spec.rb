require 'spec_helper'

module Scooter

  describe Utilities::BeakerUtilities do

    let(:result)          { instance_double(Beaker::Result)}
    let(:master)          { instance_double(Beaker::Host) }

    context 'with correct argument' do

      it 'gets the pe ca certfile' do
        cmd = "cat `puppet config print localcacert`"
        expect_any_instance_of(Beaker::DSL).to receive(:on).with(master, cmd).and_return(result)
        expect(result).to receive(:stdout).and_return('foobar_ca_cert')
        expect(File.read(subject.pe_ca_cert_file(master))).to eq('foobar_ca_cert')
      end

      it 'gets the pe hostprivkey' do
        cmd = "cat `puppet config print hostprivkey`"
        expect_any_instance_of(Beaker::DSL).to receive(:on).with(master, cmd).and_return(result)
        expect(result).to receive(:stdout).and_return('foobar_pkey')
        expect(File.read(subject.pe_private_key_file(master))).to eq('foobar_pkey')
      end

      it 'gets the pe hostcert' do
        cmd = "cat `puppet config print hostcert`"
        expect_any_instance_of(Beaker::DSL).to receive(:on).with(master, cmd).and_return(result)
        expect(result).to receive(:stdout).and_return('foobar_master_cert')
        expect(File.read(subject.pe_hostcert_file(master))).to eq('foobar_master_cert')
      end

    end

    context 'without correct arguements' do

      it 'getting the pe ca certificate fails with no arguements' do
        expect{ subject.pe_ca_cert_file }.to raise_error(ArgumentError)
      end

      it 'getting the pe hostprivkey fails with no arguements' do
        expect{ subject.pe_private_key_file }.to raise_error(ArgumentError)
      end

      it 'getting the pe hostcert fails with no arguements' do
        expect{ subject.pe_hostcert_file }.to raise_error(ArgumentError)
      end

    end

  end

end
