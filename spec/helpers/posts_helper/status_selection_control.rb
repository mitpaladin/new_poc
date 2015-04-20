
shared_examples 'a status-selection control' do
  it 'returns two HTML <option> tags' do
    expect(options.count).to eq 2
  end

  describe 'returns <option> tags for' do
    %w(draft public).each do |status|
      it status do
        regex = Regexp.new "value=\"#{status}\""
        match = options.select { |s| s.match regex }
        expect(match).not_to be nil
      end
    end
  end # describe 'returns <option> tags for'
end
