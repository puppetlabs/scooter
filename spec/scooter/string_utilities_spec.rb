require 'spec_helper'

describe Scooter::Utilities::StringUtilities::RandomString do
  describe '.generate' do
    context 'no arguements supplied' do

      it 'should generate a string 32 chars in length' do
        expect(described_class.generate).to be_a(String)
        expect(described_class.generate.length).to eq(32)
      end

    end
    context 'valid arguement' do

      it 'should generate' do
        expect(described_class.generate(78)).to be_a(String)
        expect(described_class.generate(78).length).to eq(78)
      end

    end
  end
end

describe Scooter::Utilities::StringUtilities::RandomTwoByteUnicodeString do
  describe '.generate' do
    context 'no arguements supplied' do

      it 'is encoded in utf-8' do
        expect(described_class.generate.encoding.to_s).to eq('UTF-8')
      end

      it 'all characters should be two bytes' do
        described_class.generate.each_char do |c|
          expect(c.bytesize).to eq(2)
        end
      end

      it 'string returned is 32 chars long' do
        expect(described_class.generate.length).to eq(32)
      end

    end
    context 'valid arguement' do

      it 'should return a string of the correct length' do
        length = 99
        expect(described_class.generate(length).length).to eq(length)
      end

    end

  end
end

describe Scooter::Utilities::StringUtilities::RandomHighbitString do
  describe '.generate' do
    context 'no arguements supplied' do

      it 'is encoded in ASCII-8BIT' do
        expect(described_class.generate.encoding.to_s).to eq('ASCII-8BIT')
      end

      it 'all characters should be one byte' do
        described_class.generate.each_char do |c|
          expect(c.bytesize).to eq(1)
        end
      end

      it 'string returned is 32 chars long' do
        expect(described_class.generate.length).to eq(32)
      end

    end
    context 'valid arguement' do

      it 'should return a string of the correct length' do
        length = 99
        expect(described_class.generate(length).length).to eq(length)
      end

    end
  end
end
