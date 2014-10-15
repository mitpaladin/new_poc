
shared_examples 'the #all method for a Repository' do
  context 'when records have been added' do
    let(:result) do
      all_attributes_list.each { |attribs| obj.add entity_class.new(attribs) }
      obj.all
    end

    describe 'returns an array' do
      description = %(whose length is the number of non-Guest User records in
          the User DAO).squeeze
      it description do
        # records not added until `result` lazy-evaluated
        _ = result
        dao_records = dao_class.all.reject { |u| u.slug == 'guest-user' }
        expect(result.count).to eq dao_records.count
      end

      describe 'with items' do

        it 'that are entity instances' do
          result.each { |record| expect(record).to be_an entity_class }
        end

        describe 'where each entity instance' do
          it 'corresponds to a valid instance of the corresponding DAO' do
            result.each do |record|
              dao_record = dao_class.find_by_slug record.slug
              expect(dao_record).to be_valid
            end
          end

          it 'has a unique slug' do
            slugs = []
            result.each do |record|
              slugs << record.slug unless slugs.include?(record.slug)
            end
            expect(slugs.count).to eq result.count
          end
        end # describe 'where each entity instance'
      end # describe 'with items'
    end # describe 'returns an array'
  end # context 'when records have been added'

  context 'when no records have yet been added' do
    let(:result) { obj.all }

    it 'returns an empty Array' do
      expect(result).to be_an Array
      expect(result).to be_empty
    end
  end
end # shared_examples 'the #all method for a repository'
