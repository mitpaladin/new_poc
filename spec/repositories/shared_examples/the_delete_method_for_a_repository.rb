
shared_examples 'the #delete method for a Repository' do
  context 'for an existing record' do
    let(:result) do
      obj.add entity
      obj.delete entity.slug
    end

    it 'returns the expected StoreResult' do
      expect(result).to be_success
      expect(result.entity).to be nil
      expect(result.errors).to be_empty
    end
  end # context 'for an existing record'

  context 'for a nonexistent record' do
    let(:result) { obj.delete 'nothing-here' }

    it 'returns the expected StoreResult' do
      expect(result).not_to be_success
      expect(result.entity).to be nil
      message = "A record with 'slug'=nothing-here was not found."
      expect(result.errors.first).to be_an_error_hash_for :base, message
    end
  end # context 'for a nonexistent record'
end # shared_examples 'the #delete method for a Repository'
