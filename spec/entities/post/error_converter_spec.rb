
require 'spec_helper'

require 'post/error_converter'

describe Entity::Post::ErrorConverter do
  let(:error_hashes) do
    [
      { body: 'must be specified if image URL is omitted' },
      { title: 'must not have leading whitespace' },
      { title: 'must not have extra internal whitespace' }
    ]
  end

  describe 'supports initialisation' do
    it 'with an Array of Hashes' do
      expect { described_class.new error_hashes }.not_to raise_error
    end

    it 'that accepts an empty Array' do
      expect { described_class.new [] }.not_to raise_error
    end
  end # describe 'supports initialisation'

  describe 'has an :errors reader method that' do
    let(:obj) { described_class.new error_hashes }

    it 'returns an ActiveModel::Errors instance' do
      expect(obj.errors).to be_an ActiveModel::Errors
    end

    it 'records one error for each Hash in the initialiser Array' do
      expect(obj.errors.count).to eq error_hashes.count
    end

    it 'has the correct full error message for each initializer-Array Hash' do
      error_hashes.each do |item|
        field = item.keys.first.to_s.capitalize
        expected = [field, item.values.first].join ' '
        expect(obj.errors.full_messages).to include expected
      end
    end
  end # describe 'has an :errors reader method that'
end # describe Entity::Post::ErrorConverter
