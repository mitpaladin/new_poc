
require 'spec_helper'

require 'post/attribute_container'

# Namespace containing all application-defined entities.
module Entity
  describe Post::AttributeContainer do
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

    describe 'has a #define_methods method that' do
      describe 'adds methods to the parameter object that' do
        let(:body) { 'A Body' }
        let(:title) { 'A Title' }
        let(:params) { { title: title, body: body } }

        let(:obj_class) do
          Class.new do
            def initialize(container_class, **attribs_in)
              @container = container_class.new(attribs_in).define_methods self
            end
          end
        end
        let(:obj) { obj_class.new described_class, params }

        it 'add reader methods for each attribute' do
          params.each_key { |field| expect(obj).to respond_to field }
        end

        it 'return the original attribute value from each reader method' do
          params.each { |key, value| expect(obj.send key).to eq value }
        end
      end # describe 'adds methods to the parameter object that'
    end # describe 'has a #define_methods method that' do

    describe 'has a #blacklist method that' do
      let(:body) { 'A Body' }
      let(:title) { 'A Title' }
      let(:blacklisted_attr) { :body }
      let(:params) { { title: title, body: body } }
      let(:obj_class) do
        Class.new do
          def initialize(container_class, *blacklisted_attrs, **attribs_in)
            @container = container_class.new(attribs_in)
                         .blacklist(blacklisted_attrs)
                         .define_methods self
          end
        end
      end
      let(:obj) { obj_class.new described_class, blacklisted_attr, params }
      let(:valid_attrs) { params.reject { |k, _v| k == blacklisted_attr } }

      it 'does not have accessor methods for blacklisted attributes' do
        valid_attrs.each_key { |attr| expect(obj).to respond_to attr }
        expect(obj).not_to respond_to blacklisted_attr
      end

      describe 'cannot be called after' do
        after :each do
          expect { @cont.blacklist [blacklisted_attr] }.to raise_error \
            RuntimeError, 'Too late to blacklist existing attributes'
        end

        it 'the #define_methods method has been called on that instance' do
          @cont = described_class.new(params).define_methods self
        end

        it 'the #attributes method has been called on that instance' do
          @cont = described_class.new params
          _ = @cont.attributes
        end
      end # describe 'cannot be called after'
    end # describe 'has a #blacklist method that'
  end # describe Entity::Post::AttributeContainer
end
