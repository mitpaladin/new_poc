
require 'spec_helper'

describe ErrorFactory do
  let(:klass) { ErrorFactory }

  describe :create.to_s do
    it 'returns an empty Array when an empty Hash is passed in' do
      expect(klass.create({})).to eq []
    end

    describe 'returns an array of Hashes with each Hash having' do
      let(:errors) do
        [
          { field: 'f1', message: 'm1' },
          { field: 'f1', message: 'm2' },
          { field: 'f2', message: 'm3' }
        ]
      end
      let(:actual) { klass.create errors }

      it 'two key/value pairs' do
        actual.each do |item|
          expect(item).to be_a Hash
          expect(item).to have(2).entries
        end
      end

      it 'one :field key and one :message key' do
        actual.each { |item| expect(item.keys).to eq [:field, :message] }
      end

      it 'string-like values for both keys' do
        actual.each do |item|
          item.values.each { |value| expect(value).to respond_to :to_str }
        end
      end
    end # describe 'returns an array of Hashes with each Hash having'
  end # describe :create
end # describe ErrorFactory
