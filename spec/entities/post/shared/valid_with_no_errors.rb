
shared_examples 'it is valid' do
  it 'is recognised as valid' do
    expect(obj).to be_valid
  end

  it 'has no errors' do
    expect(obj).to have(0).errors
  end
end
