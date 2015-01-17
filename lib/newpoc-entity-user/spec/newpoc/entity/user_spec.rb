
require 'spec_helper'

describe Newpoc::Entity::User do
  let(:invalid_attribs) do
    {
      bogus: 'This is invalid',
      forty_two: 41
    }
  end
  let(:valid_subset) do
    {
      name: 'Joe Blow',
      email: 'joe@example.com'
    }
  end
  let(:obj) { described_class.new valid_subset }

  it 'has a version number' do
    expect(Newpoc::Entity::User::VERSION).not_to be nil
  end

  describe 'supports initialisation' do
    describe 'succeeding' do
      let(:invalid_obj) { described_class.new invalid_attribs }

      it 'with the minimum set of valid field names' do
        expect { described_class.new valid_subset }.not_to raise_error
      end

      it 'with invalid field names' do
        expect { invalid_obj }.not_to raise_error
        invalid_attribs.each_key do |attrib|
          expect(invalid_obj[attrib]).to be nil
        end
      end
    end # describe 'succeeding'
  end # describe 'supports initialisation'

  describe '#attributes' do
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

    it 'returns the correct value for an attribute by hash index' do
      expect(obj[:name]).to eq obj.attributes[:name]
    end

    it 'returns nil for a requested attribute that does not exist' do
      expect(obj[:bogus]).to be nil
    end
  end # describe '#[]'

  describe '#persisted?' do
    it 'returns true if the "slug" attribute is present' do
      obj = described_class.new valid_subset.merge slug: 'any-slug'
      expect(obj).to be_persisted
    end

    it 'returns false if the "slug" attribute is not present' do
      expect(obj).not_to be_persisted
    end
  end # describe '#persisted?'
end # describe Newpoc::Entity::User
