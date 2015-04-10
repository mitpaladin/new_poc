
shared_examples 'a body attribute' do |it_has_no_image_url|
  it_behaves_like 'it is valid with a valid body attribute'

  context 'and the body specified in the attributes is invalid because' do
    context 'it is missing, it' do
      let(:body) { nil }

      it_behaves_like it_has_no_image_url
    end # context 'it is missing, it'

    context 'it is blank, it' do
      let(:body) { '     ' }

      it_behaves_like it_has_no_image_url
    end # context 'it is blank, it'
  end # context 'and the body specified in the attributes is invalid because'
end
