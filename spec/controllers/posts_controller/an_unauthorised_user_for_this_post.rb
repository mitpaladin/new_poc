
shared_examples 'an unauthorised user for this post' do
  it 'redirects to the posts path' do
    expect(response).to redirect_to posts_path
  end

  it 'sets the correct flash error message' do
    expect(flash[:alert]).to eq 'Not logged in as a registered user!'
  end

  it 'does not assign an object to :post' do
    expect(assigns[:post]).to be nil
  end
end # shared_examples 'an unauthorised user for this post'
