
shared_examples 'an entity with standard attributes' do |traits, attribs_in|
  let(:ctime) { Time.now }
  let(:impl) do
    build_attribs = traits + [created_at: ctime]
    FactoryGirl.build :post_datum, *build_attribs
  end
  let(:entity) { CCO::PostCCO2.to_entity impl }
  describe 'with the correct attribute values for' do
    attribs_in.each do |method_sym|
      it method_sym do
        expect(entity.send method_sym).to eq impl.send(method_sym)
      end
    end

    it :created_at do
      expected = impl.created_at
      expect(entity.created_at).to be_within(0.1.second).of expected
    end
  end # describe 'with the correct attribute values for'
end # shared_examples 'an entity with standard attributes'
