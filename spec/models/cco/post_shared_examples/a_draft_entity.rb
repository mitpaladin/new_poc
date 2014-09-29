
shared_examples 'a draft entity' do |specifier_traits|
  let(:ctime) { Time.now }
  let(:impl) do
    build_attribs = specifier_traits + [:draft_post, created_at: ctime]
    FactoryGirl.build :post_datum, *build_attribs
  end
  let(:blog) { Blog.new }
  let(:entity) { CCO::PostCCO2.to_entity impl }

  describe 'with correct' do
    before :each do
      blog.add_entry entity
      # No call to entity.publish
    end

    describe 'attribute values for' do
      it :pubdate do
        expect(entity.pubdate).to be nil
      end
    end # describe 'attribute values for'

    describe 'values returned from instance methods' do
      it :published? do
        expect(entity).not_to be_published
      end
    end # describe 'values returned from instance methods'
  end # describe 'with correct'
end # shared_examples 'a draft entity'
