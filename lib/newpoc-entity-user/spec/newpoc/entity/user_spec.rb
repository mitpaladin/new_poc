
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
      name: user_name,
      email: user_email
    }
  end
  let(:obj) { described_class.new valid_subset }
  let(:user_email) { 'joe@example.com' }
  let(:user_name) { 'Joe Blow' }
  let(:user_profile) { 'A *profile*!' }

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

  describe '#valid?' do
    # No password pair here...
    describe 'returns true when an instance has' do
      after :each do
        obj = described_class.new @attribs
        expect(obj).to be_valid
      end

      it 'the minumum valid set of attributes' do
        @attribs = valid_subset
      end

      it 'a name, email address and profile string' do
        @attribs = valid_subset.merge profile: user_profile
      end
    end # describe 'returns true when an instance has'

    describe 'returns false when an instance has' do
      after :each do
        obj = described_class.new @attribs
        expect(obj).to be_invalid
      end

      describe 'a name that is invalid because it' do
        after :each do
          @attribs = { name: @name, email: user_email, profile: user_profile }
        end

        it 'has leading/trailing whitespace' do
          @name = '  Some  Body '
        end

        it 'contains invalid whitespace' do
          @name = "Some\tBody\n"
        end

        it 'is missing' do
          @name = nil
        end
      end # describe 'a name that is invalid because it'

      it 'no email address' do
        @attribs = { name: user_name, profile: user_profile }
      end

      it 'an invalid email address' do
        @attribs = { name: user_name, email: 'joe at example dot com' }
      end
    end
  end # describe '#valid?'
end # describe Newpoc::Entity::User
