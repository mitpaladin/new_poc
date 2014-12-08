
shared_examples 'the #add method for a Repository' do
  context 'on success' do
    let!(:initial_count) { dao_class.all.count }
    let!(:result) { obj.add entity }

    it 'adds a new record to the database' do
      added_records = dao_class.all.count - initial_count
      expect(added_records).to eq 1
    end

    it 'returns the expected StoreResult' do
      expect(result).to be_success
      expect(result.errors).to be_empty
      expect(result.entity).to be_entity_for.call(entity)
    end
  end # context 'on success'

  context 'on failure' do
    let(:mockDao) do
      Class.new(dao_class) do
        def save
          # FIXME: We apparently can't just use RSpec variables here. Why not?
          errors.add :frobulator, 'is busted'
          false
        end
      end
    end
    let(:obj) do
      described_class.new factory_class, mockDao
    end
    let!(:initial_count) { mockDao.all.count }
    let(:result) { obj.add entity }

    it 'does not add a new record to the database' do
      expect(dao_class.all.count).to eq initial_count
    end

    it 'returns the expected StoreResult' do
      expect(result).not_to be_success
      expect(result.entity).to be nil
      expect(result).to have(1).error
      error = result.errors.first
      expect(error[:field]).to eq save_error_data.keys.first.to_s
      expect(error[:message]).to eq save_error_data.values.first
    end
  end # context 'on failure'
end # shared_examples 'the #add method for a Repository'
