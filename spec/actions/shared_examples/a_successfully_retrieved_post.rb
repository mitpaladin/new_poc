
shared_examples 'a successfully-retrieved post' do
  it 'is successful' do
    expect(subscriber).to be_successful
    expect(subscriber).not_to be_failure
  end

  describe 'is successful, broadcasting a payload which' do
    let(:payload) { subscriber.payload_for(:success).first }

    it 'is a Newpoc::Entity::Post' do
      expect(payload).to be_a Newpoc::Entity::Post
    end

    it 'is a Newpoc::Entity::Post with correct attributes' do
      attrib_keys = target_post.attributes.keys - [:pubdate]
      attrib_keys.each { |key| expect(payload[key]).to eq target_post[key] }
      if target_post.attributes.key? :pubdate
        expect(payload[:pubdate]).to be_within(0.5.seconds)
          .of target_post[:pubdate]
      end
    end
  end # describe 'is successful, broadcasting a payload which'
end # shared_examples 'a successfully-retrieved post'
