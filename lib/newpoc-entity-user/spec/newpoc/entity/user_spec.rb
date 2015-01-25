
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

  describe '#guest_user?' do

    it 'returns true for the Guest User' do
      expect(described_class.guest_user).to be_guest_user
    end

    it 'returns false for any other user' do
      expect(obj).not_to be_guest_user
    end
  end # describe '#guest_user?'

  describe '.guest_user' do
    it 'has the correct name' do
      expect(described_class.guest_user.name).to eq 'Guest User'
    end

    it 'is not persisted' do
      expect(described_class.guest_user).not_to be_persisted
    end

    it 'has a nil slug value' do
      expect(described_class.guest_user.slug).to be_nil
    end
  end # describe '.guest_user'

  describe '#sort' do
    let(:low_user) { described_class.new valid_subset.merge name: 'Abe Zonker' }
    let(:high_user) { described_class.new valid_subset.merge name: 'Zig Adler' }

    it 'returns the sorted array when source is not in order by name' do
      items = [high_user, low_user]
      expect(items.sort).to eq [low_user, high_user]
    end

    it 'returns a copy of the original array when in order by name' do
      items = [low_user, high_user]
      items.sort.each_with_index do |item, index|
        expect(item).to be items[index]
      end
      expect(items.sort).not_to be items
    end
  end # describe '#sort'

  describe '#formatted_profile' do
    let(:converter) do
      klass = Class.new do
        def to_html(markup)
          ['START TEST', markup, 'END TEST'].join '|'
        end
      end
      lambda do |markup|
        klass.new.to_html markup
      end
    end
    let(:profile) { 'This *is* a test.' }
    let(:user) { described_class.new user_attribs }
    let(:user_attribs) do
      valid_subset.merge markdown_converter: converter, profile: profile
    end

    it 'returns the result of calling the converter on the profile content' do
      expected = ['START TEST', profile, 'END TEST'].join '|'
      expect(user.formatted_profile).to eq expected
    end
  end # describe '#formatted_profile'
end # describe Newpoc::Entity::User
