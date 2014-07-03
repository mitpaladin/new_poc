
shared_examples 'Post-like attributes' do
  describe 'having the correct' do

    it 'title' do
      expr = /Test Title Number \d+/
      @entries.each { |entry| expect(entry.title).to match expr }
    end

    it 'body text' do
      @entries.each { |entry| expect(entry.body).to eq 'The Body' }
    end

    it 'image URL' do
      url = 'http://example.com/image1.png'
      @entries.each { |entry| expect(entry.image_url).to match url }
    end
  end # describe 'having the correct'
end # shared_examples 'Post-like attributes'
