
shared_examples 'a draft entity' do |specifier_traits|
  let(:ctime) { Time.now }
  let(:impl) do
    build_attribs = specifier_traits + [:draft_post, created_at: ctime]
    FactoryGirl.build :post_datum, *build_attribs
  end
  let(:entity) { CCO::PostCCO2.to_entity impl }
  describe 'with correct values returned from instance methods' do
    it :published? do
      expect(entity).not_to be_published
    end
  end # describe 'with correct values returned from instance methods'
end # shared_examples 'a draft entity'

