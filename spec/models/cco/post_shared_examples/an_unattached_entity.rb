
shared_examples 'an unattached entity' do |specifier_traits|
  let(:ctime) { Time.now }
  let(:impl) do
    build_attribs = specifier_traits + [created_at: ctime]
    FactoryGirl.build :post_datum, *build_attribs
  end
  let(:entity) { CCO::PostCCO2.to_entity impl }
  describe 'with the correct attribute values for' do
    it :blog do
      expect(entity.blog).to be nil
    end
  end # describe 'with the correct attribute values for'
end # shared_examples 'an unattached entity'
