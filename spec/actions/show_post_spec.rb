
require 'spec_helper'

require 'show_post'

module Actions
  describe ShowPost do
    let(:klass) { ShowPost }
    let(:author) do
      attribs = FactoryGirl.attributes_for :user, :saved_user
      UserEntity.new(attribs).tap { |user| UserRepository.new.add user }
    end
    let(:guest_user) { UserRepository.new.guest_user.entity }
    let(:repo) { PostRepository.new }
    let(:subscriber) { BroadcastSuccessTester.new }

    before :each do
      command.subscribe(subscriber).execute
    end

    context 'for an existing published post' do
      let(:command) { klass.new target_post.slug, guest_user }
      let(:target_post) do
        attribs = FactoryGirl.attributes_for :post, :saved_post, :published_post
        PostEntity.new(attribs).tap { |post| repo.add post }
      end

      it 'is successful' do
        expect(subscriber).to be_successful
        expect(subscriber).not_to be_failure
      end

      describe 'is successful, broadcasting a StoreResult payload with' do
        let(:payload) { subscriber.payload_for(:success).first }

        it 'a :success value of true' do
          expect(payload).to be_success
        end

        it 'an empty :errors item' do
          expect(payload.errors).to be_empty
        end

        it 'the target post as the :entity' do
          expect(payload.entity).to be_saved_post_entity_for target_post
        end
      end # describe 'is successful, broadcasting a StoreResult payload with'
    end # context 'for an existing published post' do

    context 'for an existing draft post' do
      let(:command) { klass.new target_post.slug, current_user }
      let(:target_post) do
        attribs = FactoryGirl.attributes_for :post, :saved_post,
                                             author_name: author.name
        PostEntity.new(attribs).tap { |post| repo.add post }
      end

      context 'being viewed by the post author' do
        let(:current_user) { author }

        it 'is successful' do
          expect(subscriber).to be_successful
          expect(subscriber).not_to be_failure
        end

        describe 'is successful, broadcasting a StoreResult payload with' do
          let(:payload) { subscriber.payload_for(:success).first }

          it 'a :success value of true' do
            expect(payload).to be_success
          end

          it 'an empty :errors item' do
            expect(payload.errors).to be_empty
          end

          it 'the target post as the :entity' do
            expect(payload.entity).to be_saved_post_entity_for target_post
          end
        end # describe 'is successful, broadcasting a StoreResult payload with'
      end # context 'being viewed by the post author'

      context 'being viewed by anyone else' do
        let(:current_user) { guest_user }

        it 'is unsuccessful' do
          expect(subscriber).not_to be_successful
          expect(subscriber).to be_failure
        end

        describe 'is unsuccessful, broadcasting a StoreResult payload with' do
          let(:payload) { subscriber.payload_for(:failure).first }

          it 'a :success value of true' do
            expect(payload).not_to be_success
          end

          it 'an :errors item with the correct information' do
            expect(payload).to have(1).error
            message = "Cannot find post with slug #{target_post.slug}!"
            expect(payload.errors.first).to be_an_error_hash_for :user, message
          end

          it 'the :entity field set to nil' do
            expect(payload.entity).to be nil
          end
        end # describe 'is unsuccessful, broadcasting a StoreResult payload...'
      end # context 'being viewed by anyone else'
    end # context 'for an existing draft post'
  end # describe Actions::ShowPost
end # module Actions
