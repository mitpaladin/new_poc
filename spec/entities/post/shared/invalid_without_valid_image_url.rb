
shared_examples 'it is invalid without a valid image URL' do
  it 'is not recognised as valid' do
    expect(obj).not_to be_valid
  end

  it 'has one error' do
    expect(obj).to have(1).error
  end

  it 'reports that the body may not be empty if no image URL' do
    expected = {
      # body: 'may not be empty if image URL is missing or empty'
      body: 'must be specified if image URL is omitted'
    }
    expect(obj.errors.first).to eq expected
  end
end
