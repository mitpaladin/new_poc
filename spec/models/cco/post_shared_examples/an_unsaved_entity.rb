
shared_examples 'an unsaved entity' do |specifier_traits|
  let(:ctime) { Time.now }
  let(:impl) do
    build_attribs = specifier_traits + [:new_post, created_at: ctime]
    FactoryGirl.build :post_datum, *build_attribs
  end
  let(:entity) { CCO::PostCCO2.to_entity impl }
  describe 'with the correct attribute values for' do
    [:pubdate, :slug].each do |method_sym|
      it method_sym do
        expect(entity.send method_sym).to be nil
      end
    end
  end # describe 'with the correct attribute values for'
end # shared_examples 'an unsaved entity'
