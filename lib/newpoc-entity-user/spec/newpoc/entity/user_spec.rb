
require 'spec_helper'

describe Newpoc::Entity::User do
  let(:valid_subset) do
    {
      name: 'Joe Blow',
      email: 'joe@example.com'
    }
  end

  it 'has a version number' do
    expect(Newpoc::Entity::User::VERSION).not_to be nil
  end

  describe 'supports initialisation' do
    describe 'succeeding' do
      it 'with the minimum set of valid field names' do
        expect { described_class.new valid_subset }.not_to raise_error
      end
    end # describe 'succeeding'

  end # describe 'supports initialisation'

  # begin 'it has initialiser-set attributes'
  describe '#attributes' do
    let(:obj) { described_class.new valid_subset }
    let(:actual) { obj.attributes }

    it 'returns the attributes passed to the initialiser' do
      valid_subset.each_pair do |attrib, value|
        expect(obj.send attrib).to eq value
      end
    end

    it 'has nil values for all attributes not passed to the initialiser' do
      actual.keys.reject { |k| valid_subset.key? k }.each do |attrib|
        expect(obj[attrib.to_s]).to be nil
      end
    end
  end # describe '#attributes'

  describe '#[]' do
    let(:obj) { described_class.new valid_subset }

    it 'returns the correct value for an attribute by hash index' do
      expect(obj[:name]).to eq obj.attributes[:name]
    end

    it 'returns nil for a requested attribute that does not exist' do
      expect(obj[:bogus]).to be nil
    end
  end # describe '#[]'
  # end 'it has initialiser-set attributes'
end # describe Newpoc::Entity::User
