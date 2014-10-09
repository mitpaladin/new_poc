
shared_examples 'an entity factory for' do |entity_class|
  describe ".create returns a #{entity_class}" do
    let(:entity) { klass.create dao }

    it 'instance' do
      expect(entity).to be_an entity_class
    end

    it 'with the same attribute values as the DAO' do
      entity.init_attrib_keys.each do |attrib|
        expect(entity.send attrib).to eq dao[attrib]
      end
    end
  end # describe ".create returns a #{entity_class}"
end
