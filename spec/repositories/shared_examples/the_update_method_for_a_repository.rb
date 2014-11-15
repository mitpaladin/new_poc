
shared_examples 'the #update method for a Repository' do
  context 'on success' do
    let!(:result) do
      r = obj.add entity
      entity = r.entity
      attribs = entity.attributes
      attribs[attribute_to_update] = updated_attribute
      entity = entity_class.new attribs
      obj.update entity
    end

    it 'updates the stored record' do
      expect(dao_class.last.send attribute_to_update).to eq updated_attribute
    end

    it 'returns the expected StoreResult' do
      expect(result).to be_success
      expect(result.errors).to be_empty
      expect(result.entity.send attribute_to_update).to eq updated_attribute
    end
  end # context 'on success'

  context 'on failure' do
    let(:error_key) { :frobulator }
    let(:error_message) { 'is busted' }
    let(:mockDao) do
      Class.new(dao_class) do
        def update_attributes(_attribs)
          # And no, this can't use RSpec variables declared earlier. Pffft.
          errors.add :frobulator, 'is busted'
          false
        end
      end
    end
    let(:obj) do
      klass.new factory_class, mockDao
    end
    let!(:result) do
      r = obj.add entity
      entity = r.entity
      attribs = entity.attributes
      attribs[attribute_to_update] = updated_attribute
      entity = entity_class.new attribs
      obj.update entity
    end

    it 'does not update the stored record' do
      expect(dao_class.last.send attribute_to_update)
        .not_to eq updated_attribute
    end

    it 'returns the expected StoreResult' do
      expect(result).not_to be_success
      expect(result.entity).to be nil
      expect(result).to have(1).error
      expect(result.errors.first)
        .to be_an_error_hash_for error_key, error_message
    end
  end # context 'on failure'

  context 'on the record not being found' do
    let(:bad_slug_return) do
      errors = ActiveModel::Errors.new dao_class.new
      errors.add :base, "A record with 'slug'=#{entity.slug} was" \
          ' not found.'
      StoreResult.new entity: nil, success: false,
                      errors: ErrorFactory.create(errors)
    end
    let(:obj) do
      ret = klass.new
      allow(ret).to receive(:find_by_slug).and_return bad_slug_return
      ret
    end
    let!(:result) do
      r = obj.add entity
      entity = r.entity
      attribs = entity.attributes
      attribs[attribute_to_update] = updated_attribute
      entity = entity_class.new attribs
      obj.update entity
    end

    it 'does not update the stored record' do
      expect(dao_class.last.send attribute_to_update)
        .not_to eq updated_attribute
    end

    it 'returns the expected StoreResult' do
      expect(result).not_to be_success
      expect(result.entity).to be nil
      expect(result).to have(1).error
      expected_message = "A record with 'slug'=#{entity.slug} was not found."
      expect(result.errors.first)
        .to be_an_error_hash_for :base, expected_message
    end
  end # context 'on the record not being found'
end # shared_examples 'the #update method for a Repository'
