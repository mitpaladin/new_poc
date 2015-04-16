
shared_examples 'an image URL attribute' do |it_has_no_body|
  it_behaves_like 'it is valid with a valid image URL attribute'

  context 'and the image URL specified in the attributes is invalid because' do
    context 'it is missing, it' do
      let(:image_url) { nil }

      it_behaves_like it_has_no_body
    end # context 'it is missing, it'

    context 'it is blank, it' do
      let(:image_url) { '     ' }

      it_behaves_like it_has_no_body
    end # context 'it is blank, it'
  end # context 'and the body specified in the attributes is invalid because'
end
