
require 'spec_helper'

require 'edit_post'

require_relative 'shared_examples/a_successfully_retrieved_post'

module Actions
  describe EditPost do
    let(:post_class) { Newpoc::Entity::Post }
    let(:target_post) do
      attribs = FactoryGirl.attributes_for :post, :saved_post,
                                           author_name: author.name
      post_class.new(attribs).tap { |ret| post_repo.add ret }
    end
    let(:post_repo) { PostRepository.new }
    let(:subscriber) { BroadcastSuccessTester.new }
    let(:user_repo) { UserRepository.new }
    let(:author) do
      attribs = FactoryGirl.attributes_for :user, :saved_user
      UserEntity.new(attribs).tap { |user| user_repo.add user }
    end

    before :each do
      command.subscribe(subscriber).execute
    end

    context 'with the post author as the current user' do
      let(:command) { described_class.new target_post.slug, author }

      it_behaves_like 'a successfully-retrieved post'
    end # context 'with the post author as the current user'

    context 'with another registered user as the current user' do
      let(:command) { described_class.new target_post.slug, other_user }
      let(:other_user) do
        attribs = FactoryGirl.attributes_for :user, :saved_user
        UserEntity.new(attribs).tap { |user| user_repo.add user }
      end

      it 'is not successful' do
        expect(subscriber).not_to be_successful
        expect(subscriber).to be_failure
      end

      describe 'it is unsuccessful, returning a payload which' do
        let(:payload) { subscriber.payload_for(:failure).first }

        it 'contains the correct error message' do
          message = "User #{other_user.name} is not the author of this post!"
          expect(payload).to eq message
        end
      end # describe 'it is unsuccessful, returning a payload which'

      context 'with an invalid slug passed to the action' do
        let(:invalid_slug) { 'invalid-slug' }
        let(:command) do
          described_class.new invalid_slug, author
        end

        it 'is unsuccessful' do
          expect(subscriber).not_to be_successful
          expect(subscriber).to be_failure
        end

        describe 'is unsuccessful, broadcasting a payload which' do
          let(:payload) { subscriber.payload_for(:failure).first }

          it 'contains the correct error message' do
            expected = "Cannot find post identified by slug: '#{invalid_slug}'!"
            expect(payload).to eq expected
          end
        end # describe 'is unsuccessful, broadcasting a payload which'
      end # context 'with an invalid slug passed to the action'
    end # context 'with another registered user as the current user'

    context 'with the Guest User as the current user' do
      let(:command) { described_class.new target_post.slug, guest_user }
      let(:guest_user) { UserRepository.new.guest_user.entity }

      it 'is not successful' do
        expect(subscriber).not_to be_successful
        expect(subscriber).to be_failure
      end

      describe 'it is unsuccessful, returning a payload which' do
        let(:payload) { subscriber.payload_for(:failure).first }

        it 'contains the correct error message' do
          expect(payload).to eq 'Not logged in as a registered user!'
        end
      end # describe 'it is unsuccessful, returning a payload which'
    end # context 'with the Guest User as the current user'
  end # describe Actions::EditPost
end # module Actions
