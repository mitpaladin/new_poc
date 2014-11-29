
require 'spec_helper'

require 'new_post'

module Actions
  describe NewPost do
    let(:klass) { NewPost }
    let(:repo) { UserRepository.new }
    let(:subscriber) { BroadcastSuccessTester.new }
    let(:current_user) do
      user = UserEntity.new FactoryGirl.attributes_for :user, :saved_user
      repo.add user
      user
    end
    let(:guest_user) { repo.guest_user.entity }

    before :each do
      command.subscribe subscriber
      command.execute
    end

    context 'with the Guest User as the current user' do
      let(:command) { klass.new repo.guest_user.entity }

      it 'is unsuccessful' do
        expect(subscriber).not_to be_successful
        expect(subscriber).to be_failure
      end

      describe 'is unsuccessful, broadcasting a PostEntity payload with' do
        let(:payload) { subscriber.payload_for(:failure).first }

        it 'one error with the correct error message' do
          expect(payload).to have(1).error
          expected = 'Author name must be that of a logged-in, registered user'
          expect(payload.errors.full_messages.first).to eq expected
        end
      end # describe 'is unsuccessful, broadcasting a PostEntity payload with'
    end # context 'with the Guest User as the current user'

    context 'with a Registered User as the current user' do
      let(:command) { klass.new current_user }

      it 'is successful' do
        expect(subscriber).to be_successful
        expect(subscriber).not_to be_failure
      end

      describe 'is successful, broadcasting a PostEntity payload' do
        let(:payload) { subscriber.payload_for(:success).first }

        it 'no existing errors' do
          expect(payload).to be_a PostEntity
          expect(payload).to have(0).errors
        end

        it 'that is not valid without a title or' do
          expect(payload).not_to be_valid
          expect(payload).to have(2).errors
          expected = [
            "Title can't be blank",
            "Body must be specified if image URL is omitted"
          ]
          expect(payload.errors.full_messages).to eq expected
        end

        it 'with the author name as the only assigned attribute' do
          expect(payload).to have(1).attribute
          expect(payload.author_name).to eq current_user.name
        end
      end # describe 'is successful, broadcasting a PostEntity payload'
    end # context 'with a Registered User as the current user'
  end # describe Actions::NewPost
end # module Actions
