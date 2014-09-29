
shared_examples 'a valid entity' do |specifier_traits|
  let(:ctime) { Time.now }
  let(:impl) do
    build_attribs = specifier_traits + [created_at: ctime]
    FactoryGirl.build :post_datum, *build_attribs
  end
  let(:entity) { CCO::PostCCO2.to_entity impl }
  describe 'with correct values returned from instance methods' do
    it :error_messages do
      entity.valid?
      expect(entity).to have(0).error_messages
    end

    it :valid? do
      expect(entity).to be_valid
    end
  end # describe 'with correct values returned from instance methods'
end # shared_examples 'a valid entity'
