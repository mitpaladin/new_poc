
shared_examples 'an invalid entity' do |bad_attr, specifier_traits|
  let(:ctime) { Time.now }
  let(:impl) do
    build_attribs = specifier_traits + [created_at: ctime]
    FactoryGirl.build(:post_datum, *build_attribs).tap do |impl|
      attr = (bad_attr.to_s + '=').to_sym
      impl.send attr, nil
    end
  end
  let(:entity) { CCO::PostCCO2.to_entity impl }
  describe 'with correct values returned from instance methods' do
    it :error_messages do
      expected = bad_attr.to_s.titleize + ' must be present'
      entity.valid?
      expect(entity.error_messages.first).to eq expected
      expect(entity).to have(1).error_messages
    end

    it :valid? do
      expect(entity).not_to be_valid
    end
  end # describe 'with correct values returned from instance methods'
end # shared_examples 'an invalid entity'
