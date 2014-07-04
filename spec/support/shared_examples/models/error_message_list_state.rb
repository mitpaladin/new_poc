
shared_examples 'error-message list empty-state check' do |is_empty|
  is_empty = true if is_empty.nil?
  if is_empty
    desc = 'returns an empty array'
    message = :empty?
  else
    desc = 'returns a non-empty array'
    message = :any?
  end

  it desc do
    expect(post.error_messages).to be_an Array
    expect(post.error_messages.send message).to be true
  end
end # shared_examples
