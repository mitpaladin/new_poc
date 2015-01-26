
require_relative '../../repositories/custom_matchers/be_same_timestamped_entity_as'

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
      expect(payload).to be_same_timestamped_entity_as target_post
    end
  end # describe 'is successful, broadcasting a payload which'
end # shared_examples 'a successfully-retrieved post'
