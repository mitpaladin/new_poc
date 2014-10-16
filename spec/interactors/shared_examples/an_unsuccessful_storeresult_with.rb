
shared_examples 'an unsuccessful StoreResult with' do |field, message|
  it 'a falsy "success" field' do
    expect(result).not_to be_success
  end

  it 'an "invalid user name or password" error message' do
    expect(result).to have(1).error
    error = OpenStruct.new result.errors.first
    expect(error.field).to eq field.to_s
    expect(error.message).to eq message
  end
end # shared_examples 'an unsuccessful StoreResult with'
