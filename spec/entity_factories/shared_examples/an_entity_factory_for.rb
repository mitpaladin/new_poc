
shared_examples 'an entity factory for' do |entity_class|
  describe ".create returns a #{entity_class}" do
    let(:entity) { described_class.create dao }

    it 'instance' do
      expect(entity).to be_an entity_class
    end

    it 'with the same attribute values as the DAO' do
      post_keys = %w(author_name body created_at image_url pubdate slug title
                     updated_at)
      user_keys = %w(created_at email name profile slug updated_at)
      attrib_keys = if dao.respond_to?(:author_name)
                      post_keys
                    else
                      user_keys
                    end
      attrib_keys.map(&:to_sym).each do |attrib|
        expect(entity.send attrib).to eq dao[attrib]
      end
    end
  end # describe ".create returns a #{entity_class}"
end
