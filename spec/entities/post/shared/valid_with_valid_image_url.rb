
shared_examples 'it is valid with a valid image URL attribute' do
  context 'and a valid image URL is specified in the attributes, it' do
    let(:image_url) { 'http://www.example.com/image1.png' }

    it_behaves_like 'it is valid'
  end # context 'and a valid body is specified in the attributes, it'
end
