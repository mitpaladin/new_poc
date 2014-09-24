
shared_examples 'a saved entity' do |specifier_traits|
  let(:ctime) { Time.now }
  let(:impl) do
    create_attribs = specifier_traits + [:saved_post, created_at: ctime]
    FactoryGirl.create :post_datum, *create_attribs
  end
  let(:entity) { CCO::PostCCO2.to_entity impl }
  describe 'with the correct attribute values for' do
    it :pubdate do
      expect(entity.pubdate).to be nil
    end

    it :slug do
      expect(entity.slug).to eq impl.slug
    end
  end # describe 'with the correct attribute values for'
end # shared_examples 'a saved entity'
