
shared_examples 'an attempt to create an invalid Post' do
  describe 'with an invalid title, the returned post instance is' do
    before :each do
      params[:title] = ''
      post :create, post_data: params
      @post = assigns[:post]
    end

    it 'not persisted' do
      expect(@post).not_to be_persisted
    end

    it 'is invalid' do
      expect(@post).to_not be_valid
    end

    it 'provides the correct error message' do
      expect(@post).to have(1).error
      expected = 'Title must be present and must not contain leading or' \
        ' trailing whitespace'
      expect(@post.errors.full_messages).to include expected
    end
  end # describe 'with an invalid title, the returned post instance is'
end # shared_examples 'an attempt to create an invalid Post'
