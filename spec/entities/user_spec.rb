
require 'spec_helper'

require 'user'

describe Entity::User do
  let(:minimal_attributes) do
    {
      name: 'Some User',
      email: 'some.user@example.com'
    }
  end
  let(:obj) { described_class.new minimal_attributes }

  describe 'supports initialisation' do
    describe 'succeeding with' do
      it 'the minimal set of specified attributes' do
        expect { described_class.new minimal_attributes }.not_to raise_error
      end

      describe 'invalid attribute names such that' do
        let(:invalid_attributes) do
          {
            bogus: 'This is invalid',
            forty_two: 42
          }
        end

        it 'no error is raised' do
          expect { described_class.new invalid_attributes }.not_to raise_error
        end

        it 'no invalid attributes are actually set' do
          obj = described_class.new invalid_attributes
          invalid_attributes.each_key do |attrib|
            expect(obj[attrib]).to be nil
          end
        end
      end # describe 'invalid attribute names such that'
    end # describe 'succceeding with'
  end # describe 'supports initialisation'

  describe 'has an #attributes method that returns' do
    let(:actual) { obj.attributes }

    it 'a Hash-like object' do
      expect(actual).to respond_to :to_hash
    end

    it 'the attributes passed to #initialize' do
      minimal_attributes.each_pair do |attrib, value|
        expect(obj.attributes[attrib]).to eq value
      end
    end

    it 'nil values for all attributes not set' do
      [:profile, :bogus, 'invalid key'.to_sym].each do |attr|
        expect(obj.attributes[attr]).to be nil
      end
    end
  end # describe 'has an #attributes method that returns'

  describe 'has a #[] method that is' do
    it 'aliased to the #attributes method' do
      actual = obj.attributes[:name]
      # not just same value; same *instance* of same value object
      expect(actual.hash).to be obj[:name].hash
    end
  end # describe 'has a #[] method that is'

  describe 'has a #valid? method that' do
    describe 'returns true when an instance has' do
      after :each do
        expect(described_class.new @attribs).to be_valid
      end

      it 'the minimum valid set of attributes' do
        @attribs = minimal_attributes
      end

      it 'a name, email address and profile string' do
        @attribs = minimal_attributes.merge profile: 'User Profile'
      end
    end # describe 'returns true when an instance has'

    describe 'returns false when an instance has' do
      after :each do
        expect(described_class.new @attribs).to be_invalid
      end

      describe 'a name that is invalid because it' do
        after :each do
          @attribs = { name: @name, email: 'user@example.com' }
        end

        it 'has leading whitespace' do
          @name = '  Some User'
        end

        it 'has trailling whitespace' do
          @name = 'Some User  '
        end

        it 'contains invalid whitespace' do
          @name = "Some\tUser\n"
        end

        it 'is missing' do
          @name = nil
        end
      end # describe 'a name that is invalid because it'

      describe 'an email address that is' do
        after :each do
          @attribs = { name: 'User Name', email: @email }
        end

        it 'invalid' do
          @email = 'This is not a valid email address. Sorry'
        end

        it 'missing' do
          @email = nil
        end
      end
    end # describe 'returns false when an instance has'
  end # describe 'has a #valid? method that'
end # describe Entity::User
