
shared_examples 'it has slug-based persistence-status checking' do
  describe '#persisted?' do
    it 'returns true if the "slug" attribute is present' do
      expect(klass.new valid_subset).to be_persisted
    end

    it 'returns false if the "slug" attribute is not present' do
      params = valid_subset.reject { |k, _v| k == :slug }
      expect(klass.new params).not_to be_persisted
    end
  end # describe '#persisted?'
end
