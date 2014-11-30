
shared_examples 'a successfully-retrieved post' do
  it 'is successful' do
    expect(subscriber).to be_successful
    expect(subscriber).not_to be_failure
  end

  describe 'is successful, broadcasting a payload which' do
    let(:payload) { subscriber.payload_for(:success).first }

    it 'is a PostEntity' do
      expect(payload).to be_a PostEntity
    end

    it 'is a PostEntity with correct attributes' do
      attrib_keys = target_post.attributes.keys.reject { |k| k == :pubdate }
      attrib_keys.each { |key| expect(payload[key]).to eq target_post[key] }
      if target_post.attributes.key? :pubdate
        expect(payload[:pubdate]).to be_within(0.5.seconds)
          .of target_post[:pubdate]
      end
    end
  end # describe 'is successful, broadcasting a payload which'
end
