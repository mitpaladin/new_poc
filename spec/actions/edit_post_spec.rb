
require 'spec_helper'

require 'edit_post'

module Actions
  describe EditPost do
    let(:klass) { EditPost }
    let(:post) do
      attribs = FactoryGirl.attributes_for :post, :saved_post,
                                           author_name: author.name
      PostEntity.new(attribs).tap { |ret| post_repo.add ret }
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
      let(:command) { klass.new post.slug, author }

      it 'is successful' do
        expect(subscriber).to be_successful
        expect(subscriber).not_to be_failure
      end

      describe 'it is successful, returning a StoreResult with' do
        let(:payload) { subscriber.payload_for(:success).first }

        it 'a :success value of true' do
          expect(payload).to be_success
        end

        it 'an empty :errors field' do
          expect(payload.errors).to be_empty
        end

        describe 'an :entity field that' do
          let(:entity) { payload.entity }

          it 'is a PostEntity instance' do
            expect(entity).to be_a PostEntity
          end

          it 'containing the specified post' do
            expect(entity).to be_saved_post_entity_for post
          end
        end # describe 'an :entity field that'
      end # describe 'it is successful, returning a StoreResult with'
    end # context 'with the post author as the current user'

    context 'with another registered user as the current user' do
      let(:command) { klass.new post.slug, other_user }
      let(:other_user) do
        attribs = FactoryGirl.attributes_for :user, :saved_user
        UserEntity.new(attribs).tap { |user| user_repo.add user }
      end

      it 'is not successful' do
        expect(subscriber).not_to be_successful
        expect(subscriber).to be_failure
      end

      describe 'it is unsuccessful, returning a StoreResult with' do
        let(:payload) { subscriber.payload_for(:failure).first }

        it 'a :success value of false' do
          expect(payload).not_to be_success
        end

        it 'an :errors field containing the correct error information' do
          expect(payload).to have(1).error
          message = "User #{other_user.name} is not the author of this post!"
          expect(payload.errors.first).to be_an_error_hash_for :post, message
        end

        it 'an :entity field of nil' do
          expect(payload.entity).to be nil
        end
      end # describe 'it is unsuccessful, returning a StoreResult with'
    end # context 'with another registered user as the current user'

    context 'with the Guest User as the current user' do
      let(:command) { klass.new post.slug, guest_user }
      let(:guest_user) { UserRepository.new.guest_user.entity }

      it 'is not successful' do
        expect(subscriber).not_to be_successful
        expect(subscriber).to be_failure
      end

      describe 'it is unsuccessful, returning a StoreResult with' do
        let(:payload) { subscriber.payload_for(:failure).first }

        it 'a :success value of false' do
          expect(payload).not_to be_success
        end

        it 'an :errors field containing the correct error information' do
          expect(payload).to have(1).error
          message = "Not logged in as a registered user!"
          expect(payload.errors.first).to be_an_error_hash_for :user, message
        end

        it 'an :entity field of nil' do
          expect(payload.entity).to be nil
        end
      end # describe 'it is unsuccessful, returning a StoreResult with'
    end # context 'with the Guest User as the current user'

  end # describe Actions::EditPost
end # module Actions
