
shared_examples 'an unauthorised user for this post' do |message = nil|
  default = /User .+? is not the author of this post\!/
  message = default unless message

  it 'redirects to the root path' do
    expect(response).to redirect_to root_path
  end

  it 'sets the correct flash error message' do
    expect(flash[:alert]).to match message
  end

  it 'does not assign an object to :post' do
    expect(assigns[:post]).to be nil
  end
end # shared_examples 'an unauthorised user for this post'
