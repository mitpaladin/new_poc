
shared_examples 'it has initialiser-set attributes' do
  describe '#attributes' do
    let(:obj) { described_class.new valid_subset }
    let(:actual) { obj.attributes }

    it 'returns the attributes passed to the initialiser' do
      valid_subset.each_pair do |attrib, value|
        expect(obj.send attrib).to eq value
      end
    end

    it 'has nil values for all attributes not passed to the initialiser' do
      actual.keys.reject { |k| valid_subset.key? k }.each do |attrib|
        expect(obj[attrib.to_s]).to be nil
      end
    end
  end # describe '#attributes'
end
