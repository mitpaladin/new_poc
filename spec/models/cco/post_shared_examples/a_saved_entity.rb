
shared_examples 'a saved entity' do |specifier_traits|
  let(:impl) do
    build_attribs = specifier_traits + [:draft_post]
    FactoryGirl.create :post_datum, *build_attribs
  end
  let(:blog) { Blog.new }
  let(:entity) { CCO::PostCCO2.to_entity impl }

  describe 'with the correct' do
    before :each do
      blog.add_entry entity
    end

    describe 'attribute values for' do
      it :slug do
        expect(entity.slug).to eq impl.slug
        expect(entity.slug).not_to be nil
      end
    end # describe 'attribute values for'
  end # describe 'with the correct'
end # shared_examples 'a saved entity'
