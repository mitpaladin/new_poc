
shared_examples 'the #update method for a Repository' do
  context 'on success' do
    let!(:result) do
      r = obj.add entity
      entity = r.entity
      new_attribs = OpenStruct.new
      new_attribs[attribute_to_update] = updated_attribute
      obj.update identifier: entity.slug, updated_attrs: new_attribs
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
        def update(_attribs)
          # And no, this can't use RSpec variables declared earlier. Pffft.
          errors.add :frobulator, 'is busted'
          false
        end
      end
    end
    let(:obj) do
      described_class.new factory_class, mockDao
    end
    let!(:result) do
      r = obj.add entity
      entity = r.entity
      new_attribs = OpenStruct.new
      new_attribs[attribute_to_update] = updated_attribute
      obj.update identifier: entity.slug, updated_attrs: new_attribs
    end

    it 'does not update the stored record' do
      expect(dao_class.last.send attribute_to_update)
        .not_to eq updated_attribute
    end

    it 'returns the expected StoreResult' do
      expect(result).not_to be_success
      expect(result.entity).to be nil
      expect(result).to have(1).error
      expected = {}.tap { |h| h[error_key] = [error_message] }
      expect(result.errors.messages).to eq expected
    end
  end # context 'on failure'
end # shared_examples 'the #update method for a Repository'
