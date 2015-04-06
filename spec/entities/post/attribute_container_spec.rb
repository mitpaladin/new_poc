
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
  end # describe Entity::Post::AttributeContainer
end
