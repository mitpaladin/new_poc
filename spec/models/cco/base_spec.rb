
require 'spec_helper'

require 'cco/base'

# Cross-layer conversion objects (CCOs).
module CCO
  describe Base do
    let(:klass) { Base }

    it 'has a .from_entity class method' do
      p = klass.public_method :from_entity
      expect(p.receiver).to be klass
    end

    it 'has a .to_entity class method' do
      p = klass.public_method :to_entity
      expect(p.receiver).to be klass
    end

    describe :from_entity do

      before :each do
        class TestEntity
        end

        # Dummy ActiveRecord class for testing purposes
        class TestModel
          include ActiveAttr::BasicModel
          attr_accessor :valid_flag
          validates :valid_flag, inclusion: { in: [true] }
        end
      end

      describe 'validates the implementation model before returning, so that' do

        it 'a valid entity (and thus model) produce no errors' do
          entity = TestEntity.new
          new_impl = TestModel.new
          new_impl.valid_flag = true
          params = FancyOpenStruct.new entity: entity, new_impl: new_impl
          impl = klass.from_entity params
          expect(impl).to be_valid
          expect(impl.errors.full_messages).to be_empty
        end
      end # describe 'validates the implementation model before returning, ...'
    end # describe :from_entity
  end # describe Base
end # module CCO
