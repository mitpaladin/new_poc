
shared_examples 'it is invalid without a valid primary attribute' do
  # FIXME: old message
  # message = "must be specified if #{other_name} is omitted"
  # proposed new message
  # message = "may not be empty if #{other_name} is missing or empty"

  it 'is not recognised as valid' do
    expect(obj).not_to be_valid
  end

  it 'has one error' do
    expect(obj).to have(1).error
  end

  it 'reports that the primary attribute may not be empty if no secondary' do
    expected = {
      first: 'must be specified if second is omitted'
    }
    expect(obj.errors.first).to eq expected
  end
end
