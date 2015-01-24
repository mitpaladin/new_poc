
require_relative '../custom_matchers/be_same_timestamped_entity_as'

shared_examples 'the #find_by_slug method for a Repository' do
  context 'record not found' do

    it 'returns the expected StoreResult' do
      result = obj.find_by_slug :nothing_here
      expect(result).not_to be_success
      expect(result.entity).to be nil
      expect(result).to have(1).error
      expected_message = "A record with 'slug'=nothing_here was not found."
      expect(result.errors.first)
        .to be_an_error_hash_for :base, expected_message
    end
  end # context 'record not found'

  context 'record exists' do
    let(:result) do
      obj.add entity
      obj.find_by_slug entity.slug
    end

    describe 'returns the expected StoreResult, including' do

      it 'a :success flag of true' do
        expect(result).to be_success
      end

      it 'an empty :errors collection' do
        expect(result.errors).to be_empty
      end

      describe 'an entity that has the correct' do
        it 'class' do
          expect(result.entity).to be_a entity_class
        end

        it 'domain-data field values' do
          expect(entity).to be_same_timestamped_entity_as result.entity
        end
      end # describe 'an entity that has the correct'
    end # describe 'returns the expected StoreResult, including'
  end # context 'record exists'
end # shared_examples 'the #find_by_slug method for a Repository'
