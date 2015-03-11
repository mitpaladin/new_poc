
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
end # describe Entity::User
