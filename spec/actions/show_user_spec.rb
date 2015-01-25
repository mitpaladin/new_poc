
require 'spec_helper'

require 'show_user'

module Actions
  describe ShowUser do
    let(:command) { described_class.new target_user.slug }
    let(:repo) { UserRepository.new }
    let(:subscriber) { BroadcastSuccessTester.new }

    before :each do
      command.subscribe subscriber
      command.execute
    end

    context 'for an existing user profile' do
      let(:target_user) do
        user_attribs = FactoryGirl.attributes_for :user, :saved_user
        user = UserPasswordEntityFactory.create user_attribs, 'password'
        repo.add user
        user
      end

      it 'is successful' do
        expect(subscriber).to be_successful
        expect(subscriber).not_to be_failure
      end

      describe 'is successful, broadcasting a payload which' do
        let(:payload) { subscriber.payload_for(:success).first }

        it 'is the requested User entity' do
          expect(payload).to be_a Newpoc::Entity::User
          expect(payload).to eq target_user
        end
      end # describe 'is successful, broadcasting a payload which'
    end # context 'for an existing user profile' do

    context 'for a nonexistent user profile' do
      let(:target_user) { FancyOpenStruct.new slug: 'invalid-user-slug' }

      it 'is not successul' do
        expect(subscriber).not_to be_successful
        expect(subscriber).to be_failure
      end

      describe 'is unsuccessful, broadcasting a payload which' do
        let(:payload) { subscriber.payload_for(:failure).first }

        it 'is the correct error message' do
          expected = "Cannot find user identified by slug #{target_user.slug}!"
          expect(payload).to eq expected
        end
      end # describe 'is unsuccessful, broadcasting a payload which'
    end # context 'for a nonexistent user profile'
  end # describe Actions::ShowUser
end # module Actions
