
shared_examples 'it is invalid without a valid primary attribute' do
  it 'is not recognised as valid' do
    expect(obj).not_to be_valid
  end

  it 'has one error' do
    expect(obj).to have(1).error
  end

  it 'reports that the primary attribute may not be empty if no secondary' do
    expected = {
      first: 'may not be empty if second is missing or empty'
    }
    expect(obj.errors.first).to eq expected
  end
end
