
shared_examples 'a successful StoreResult' do
  it 'a :success field of "true"' do
    expect(result).to be_success
  end

  it 'an empty :errors field' do
    expect(result.errors).to be_empty
  end
end # shared_examples 'a successful StoreResult'
