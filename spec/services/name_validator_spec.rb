
require 'spec_helper'

require 'name_validator'

shared_examples 'an invalid name' do |description, name_in, message|
  context description do
    let(:name) { name_in }

    it 'is not valid' do
      expect(validator).not_to be_valid
    end

    it 'has one error' do
      expect(validator).to have(1).error
    end

    it 'has the correct error message' do
      expect(validator.errors.first.keys.first).to be :name
      expect(validator.errors.first.values.first).to eq message
    end
  end # context description
end # shared_examples 'aan invalid name'

# Support classes for UserDataValidator.
module UserDataValidation
  describe NameValidator do
    let(:klass) { NameValidator }
    let(:validator) { klass.new name }

    context 'for a valid name' do
      let(:name) { 'Joe Blow' }

      it 'is valid' do
        expect(validator).to be_valid
      end

      it 'has no errors' do
        expect(validator).to have(0).errors
      end
    end # context 'for a valid name'

    context 'for a name that is invalid because' do

      message = 'may not be missing or blank'

      it_behaves_like 'an invalid name', 'it is missing', nil, message

      it_behaves_like 'an invalid name', 'it is blank', '   ', message

      # FIXME: DRY this up.
      context 'it is unavailable' do
        let(:existing_record) { FactoryGirl.create :user, :saved_user }
        let(:name) { existing_record.name }

        it 'is not valid' do
          expect(validator).not_to be_valid
        end

        it 'has one error' do
          expect(validator).to have(1).error
        end

        it 'has the correct error message' do
          expect(validator.errors.first.keys.first).to be :name
          expect(validator.errors.first.values.first).to eq 'is not available'
        end
      end # context 'it is unavailable'

      # Original below. This doesn't work; why is a bit subtle.
      # record = FactoryGirl.create :user, :saved_user
      # attributes = FactoryGirl.attributes_for :user, :saved_user
      # UserRepository.new.add UserEntity.new(attributes)
      # it_behaves_like 'an invalid name', 'it is unavailable', record.name,
      #                 'Name is not available'
      # record.destroy

      it_behaves_like 'an invalid name', 'it is improperly formatted',
                      "   Joe \nBlow  ", 'is not properly formatted'

      it_behaves_like 'an invalid name', 'it has repeated whitespace',
                      'Joe  Blow', 'may not contain adjacent whitespace'
    end # context 'for a name that is invalid because'
  end # describe UserDataValidation::NameValidator
end # module UserDataValidation
