
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

    it 'returns the expected StoreResult' do
      expect(result).to be_success
      expect(result.errors).to be_empty
      expect(result.entity).to be_a entity_class
      expect(result.entity).to be_entity_for.call(entity)
    end
  end # context 'record exists'
end # shared_examples 'the #find_by_slug method for a Repository'
