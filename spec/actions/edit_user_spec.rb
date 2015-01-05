
require 'spec_helper'

require 'edit_user'

module Actions
  describe EditUser do
    let(:klass) { EditUser }
    let(:repo) { UserRepository.new }
    let(:subscriber) { BroadcastSuccessTester.new }
    let(:current_user) do
      user_attribs = FactoryGirl.attributes_for :user, :saved_user
      user = UserPasswordEntityFactory.create user_attribs, 'password'
      repo.add user
      user
    end

    before :each do
      command.subscribe subscriber
      command.execute
    end

    context 'with the Guest User as the current user' do
      let(:command) { klass.new current_user.slug, repo.guest_user.entity }

      it 'is not successful' do
        expect(subscriber).not_to be_successful
        expect(subscriber).to be_failure
      end

      describe 'is not successful, broadcasting a payload which' do
        let(:payload) { subscriber.payload_for(:failure).first }

        it 'is the appropriate error message' do
          expect(payload).to eq "Not logged in as #{current_user.name}!"
        end
      end # describe 'is not successful, broadcasting a payload which'
    end # context 'with the Guest User as the current user'

    context 'with the profile owner as the current user' do
      let(:command) { klass.new current_user.slug, current_user }

      it 'is successful' do
        expect(subscriber).to be_successful
        expect(subscriber).not_to be_failure
      end

      describe 'is successful, broadcasting a payload which' do
        let(:payload) { subscriber.payload_for(:success).first }

        it 'is a UserEntity corresponding to the current user' do
          expect(payload).to be_a UserEntity
          expect(payload).to be_saved_user_entity_for current_user
        end
      end # describe 'is successful, broadcasting a payload which'
    end # context 'with the profile owner as the current user'
  end # describe Actions::EditUser
end # module Actions
