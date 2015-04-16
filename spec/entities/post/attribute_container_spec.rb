
require 'spec_helper'

require 'post/attribute_container'

# Namespace containing all application-defined entities.
module Entity
  describe Post::AttributeContainer do
    let(:body) { 'A Body' }
    let(:title) { 'A Title' }
    let(:params) { { title: title, body: body } }

    describe 'can be instantiated with' do
      after :each do
        expect { described_class.new @attribs }.not_to raise_error
      end

      describe 'a Hash containing' do
        it 'no items' do
          @attribs = {}
        end

        it 'one item' do
          @attribs = { title: 'A Title' }
        end

        it 'multiple items' do
          @attribs = {
            foo: 'bar',
            title: 'A Title',
            meaning_of_life: 42,
            meaning_of_universe: nil
          }
        end
      end # describe 'a Hash containing'

      describe 'a keyed collection of values, such as a' do
        it 'FancyOpenStruct' do
          @attribs = FancyOpenStruct.new foo: 'bar', title: 'A Title'
        end

        it 'ValueObject::Base instance' do
          @attribs = Class.new(ValueObject::Base) do
            has_fields :foo, :title
          end.new foo: 'bar', title: 'A Title'
        end
      end # describe 'a keyed collection of values, such as a'
    end # describe 'can be instantiated with'

    describe 'it cannot be instantiated with' do
      it 'something that does not respond to #to_hash' do
        expected = /undefined method \`to_hash\'/
        expect { described_class.new 'oops' }.to raise_error NoMethodError,
                                                             expected
      end
    end

    describe 'has an #attributes method that returns' do
      let(:obj) { described_class.new foo: :bar }

      it 'a ValueObject::Base instance' do
        expect(obj.attributes).to be_a ValueObject::Base
      end

      describe 'an object that' do
        it 'includes the specified attribute values' do
          expect(obj.attributes.foo).to be :bar
        end

        it 'includes no other attribute values' do
          expect(obj.attributes.to_hash.count).to eq 1
        end

        it 'does not support undefined "attributes"' do
          expect(obj).not_to respond_to :nonexistent_attribute
          expect(obj.attributes.to_hash).not_to include :nonexistent_attribute
        end

        describe 'attributes correctly when initialised with' do
          it 'string keys' do
            obj = described_class.new 'foo' => :bar, 'meaning' => 42
            expect(obj.attributes.foo).to be :bar
            expect(obj.attributes.to_hash[:meaning]).to be 42
          end
        end # describe 'attributes correctly when initialised with'
      end # describe 'an object that'
    end # describe 'has an #attributes method that returns'

    describe 'has a #keys method that returns' do
      let(:obj) do
        described_class.new foo: 'bar', bar: 'none', sense: nil, meaning: 42
      end

      it 'an array of symbols identifying the attributes in the instance' do
        expect(obj.keys.sort).to eq [:bar, :foo, :meaning, :sense]
      end
    end

    describe 'has a .blacklist_from class method that' do
      let(:blacklisted_param) { :body }
      let(:src) { described_class.new params }

      it 'produces an object without the blacklisted attributes' do
        obj = described_class.blacklist_from src, blacklisted_param
        expect(src.attributes.to_hash).to include blacklisted_param
        expect(obj.attributes.to_hash).not_to include blacklisted_param
      end
    end # describe 'has a .blacklist_from class method that'

    describe 'has a .whitelist_from class method that' do
      let(:whitelisted_param) { :body }
      let(:other_params) do
        params.keys.reject { |k| k == whitelisted_param }
      end
      let(:src) { described_class.new params }

      it 'produces an object without the whitelisted attributes' do
        obj = described_class.whitelist_from src, whitelisted_param
        expect(obj.attributes.to_hash).to include whitelisted_param
        other_params.each do |attr|
          expect(src.attributes.to_hash).to include attr
          expect(obj.attributes.to_hash).not_to include attr
        end
      end
    end # describe 'has a .whitelist_from class method that'
  end # describe Entity::Post::AttributeContainer
end
