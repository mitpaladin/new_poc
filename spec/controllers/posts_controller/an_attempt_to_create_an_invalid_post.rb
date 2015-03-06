
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
      expect(@post.errors.full_messages).to include "Title can't be blank"
    end
  end # describe 'with an invalid title, the returned post instance is'
end # shared_examples 'an attempt to create an invalid Post'
