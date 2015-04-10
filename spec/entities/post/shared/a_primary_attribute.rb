
shared_examples 'a primary attribute' do |it_has_no_secondary|
  context 'and a valid primary attribute is specified' do
    let(:attrib1) { 'Primary Attribute' }

    it_behaves_like 'it is valid'
  end # context 'and a valid primary attribute is specified'

  context 'and the specified primary attribute is invalid because' do
    context 'it is missing, it' do
      let(:attrib1) { nil }

      it_behaves_like it_has_no_secondary
    end # context 'it is missing, it'

    context 'it is blank, it' do
      let(:attrib1) { '     ' }

      it_behaves_like it_has_no_secondary
    end # context 'it is blank, it'
  end # context 'and the specified primary attribute is invalid because'
end
