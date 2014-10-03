
shared_examples 'an unauthorised user for this post' do
  it 'redirects to the root path' do
    expect(response).to redirect_to root_path
  end

  it 'sets the correct flash error message' do
    message = 'You are not authorized to perform this action.'
    expect(flash[:error]).to eq message
  end

  it 'does not assign an object to :post' do
    expect(assigns[:post]).to be nil
  end
end # shared_examples 'an unauthorised user for this post'
