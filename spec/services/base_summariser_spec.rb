
require 'spec_helper'

require 'base_summariser'

describe BaseSummariser do
  let(:data_length) { 20 }
  let(:default_length) { 10 }

  describe 'responds to DSL methods including' do
    [:selector, :sorter, :orderer, :chunker].each do |sym|
      it sym.to_s do
        expect(described_class.new).to respond_to sym
      end
    end
  end # describe 'responds to DSL methods including'
  description = 'when used without a configuration block, returns the first' \
      ' 10 items of whatever collection is passed to #summarise_data,' \
      ' including for'
  describe description do
    let(:obj) { described_class.new }

    it 'an Array' do
      data = ['a'] * (default_length * 2)
      expect(obj.summarise_data data).to eq ['a'] * default_length
    end

    it 'a Hash' do
      q = {}
      20.times { |n| q["key#{n}".to_sym] = n }
      actual = obj.summarise_data q
      expect(actual).to have(default_length).items
      default_length.times { |n| expect(actual[n]).to eq ["key#{n}".to_sym, n] }
    end
  end # describe 'when used without a configuration block, returns...'

  describe 'requires that the data supplied responds to the :take method' do
    let(:obj) { described_class.new }
    let(:data) { 'a' * data_length }

    it 'and succeeds if it does' do
      data.define_singleton_method :take do |n|
        slice 0, n
      end

      expect(obj.summarise_data data).to eq 'a' * default_length
    end

    it 'and raises a NoMethodError if it does not' do
      message = %(undefined method `take' for "aaaaaaaaaaaaaaaaaaaa":String)
      expect { obj.summarise_data data }.to raise_error NoMethodError, message
    end
  end # describe 'requires that the data supplied responds to the :take method'

  describe 'when used with a configuration block' do
    let!(:data) do
      ret = [0] * data_length
      data_length.times { |n| ret[n] += n }
      ret
    end

    it '#count' do
      obj = described_class.new do |summ|
        summ.count = 4
      end

      expect(obj.summarise_data data).to have(4).items
    end

    it '#selector' do
      obj = described_class.new do
        selector -> (data) { data.select(&:even?) }
      end

      actual = obj.summarise_data data
      expect(actual).to have(data_length / 2).items
      actual.each_with_index { |v, n| expect(v).to eq n * 2 }
    end

    it '#sorter' do
      obj = described_class.new do
        sorter -> (data) { data.reverse }
      end

      expect(obj.summarise_data data).to eq data.reverse.take default_length
    end

    it '#orderer' do
      obj = described_class.new do
        orderer -> (data) { data.reverse }
      end

      expect(obj.summarise_data data).to eq data.reverse.take default_length
    end

    it '#chunker' do
      new_length = 3
      obj = described_class.new do
        chunker -> (data) { data.take new_length }
      end

      expect(obj.summarise_data data).to eq data.take(new_length)
    end
  end # describe 'when used with a configuration block'
end # describe BaseSummariser
