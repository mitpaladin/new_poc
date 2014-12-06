
require 'spec_helper'

require 'index_users'

# Short and sweet. There are presently no parameters or failure case defined.

module Actions
  describe IndexUsers do
    let(:klass) { IndexUsers }
    let(:repo) { UserRepository.new }
    let(:subscriber) { BroadcastSuccessTester.new }
    let(:user_count) { 5 }
    let(:users) { [] }
    let(:command) { klass.new }

    before :each do
      user_count.times do
        attribs = FactoryGirl.attributes_for :user, :saved_user
        user = UserEntity.new attribs
        repo.add user
        users << user
      end
      command.subscribe subscriber
      command.execute
    end

    it 'is successful' do
      expect(subscriber).to be_successful
      expect(subscriber).not_to be_failure
    end

    describe 'is successful, broadcasting a payload which' do
      let(:payload) { subscriber.payload_for(:success).first }

      it 'is an enumeration of UserEntity instances' do
        expect(payload).to be_an Enumerable
        payload.each { |user_item| expect(user_item).to be_a UserEntity }
      end

      it 'has the correct number of entities' do
        expect(payload).to have(users.count).items
      end

      it 'has the same entities in the same order as those added' do
        users.each_with_index do |user, index|
          expect(payload[index]).to be_saved_user_entity_for user
        end
      end
    end # describe 'is successful, broadcasting a payload which'
  end # describe Actions::IndexUsers
end # module Actions
