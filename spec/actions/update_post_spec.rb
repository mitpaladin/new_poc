
require 'spec_helper'

require 'update_post'

module Actions
  describe UpdatePost do
    let(:klass) { UpdatePost }
    let(:command) { klass.new post_slug, post_data, current_user }
    let(:subscriber) { BroadcastSuccessTester.new }
    let(:user_repo) { UserRepository.new }
    let(:author) do
      FactoryGirl.create(:user, :saved_user).tap { |user| user_repo.add user }
    end
    let(:post) do
      attributes = FactoryGirl.attributes_for :post, :saved_post,
                                              :published_post,
                                              author_name: author.name
      PostEntity.new(attributes).tap { |post| PostRepository.new.add post }
    end

    # regardless of parameters, these steps wire up the Wisper connection
    before :each do
      command.subscribe(subscriber).execute
    end

    context 'for the post author' do
      let(:current_user) { author }
      let(:post_slug) { post.slug }

      context 'updating supported attributes with new valid values' do
        let(:post_data) { { body: 'Updated Post Body', title: 'A New Title'} }

        it 'is successful' do
          expect(subscriber).to be_successful
          expect(subscriber).not_to be_failure
        end

        describe 'is successful, broadcasting a StoreResult payload with' do
          let(:payload) { subscriber.payload_for(:success).first }

          it 'a :success value of true' do
            expect(payload).to be_success
          end

          it 'an empty :errors field' do
            expect(payload.errors).to be_empty
          end

          it 'an :entity field with the updated PostEntity' do
            expect(payload.entity).to be_a PostEntity
            expect(payload.entity.body).to eq post_data[:body]
            expect(payload.entity.slug).to eq post.slug
          end
        end # describe 'is successful, broadcasting a StoreResult payload with'
      end # context 'updating supported attributes with new valid values'

      context 'attempting to update supported attributes with invalid values' do
        let(:post_data) { { title: '', body: '', image_url: '' } }

        it 'is unsuccessful' do
          expect(subscriber).not_to be_successful
          expect(subscriber).to be_failure
        end

        describe 'is unsuccessful, broadcasting a StoreResult payload with' do
          let(:payload) { subscriber.payload_for(:failure).first }

          it 'a :success value of false' do
            expect(payload).not_to be_success
          end

          it 'an :errors field with the correct information' do
            message = 'Invalid attribute values specified for update!'
            expect(payload.errors.first).to be_an_error_hash_for :post, message
          end

          it 'an :entity value of nil' do
            expect(payload.entity).to be nil
          end
        end # describe 'is unsuccessful, broadcasting a StoreResult payload with'
      end # context 'attempting to update supported attributes with invalid...'
    end # context 'for the post author'

    context 'for a registered user other than the post author' do
      let(:current_user) do
        FactoryGirl.create(:user, :saved_user).tap { |user| user_repo.add user }
      end
      let(:post_slug) { post.slug }
      let(:post_data) { {} }

      it 'is unsuccessful' do
        expect(subscriber).not_to be_successful
        expect(subscriber).to be_failure
      end

      describe 'is unsuccessful, broadcasting a StoreResult payload with' do
        let(:payload) { subscriber.payload_for(:failure).first }

        it 'a :success value of false' do
          expect(payload).not_to be_success
        end

        it 'an :errors field with the correct information' do
          message = 'Not logged in as the author of this post!'
          expect(payload.errors.first).to be_an_error_hash_for :user, message
        end

        it 'an :entity value of nil' do
          expect(payload.entity).to be nil
        end
      end # describe 'is unsuccessful, broadcasting a StoreResult payload with'
    end # context 'for a registered user other than the post author'

    context 'for the Guest User' do
      let(:post_slug) { 'anything' }
      let(:post_data) { {} }
      let(:current_user) { UserRepository.new.guest_user.entity }

      it 'is unsuccessful' do
        expect(subscriber).not_to be_successful
        expect(subscriber).to be_failure
      end

      describe 'is unsuccessful, broadcasting a StoreResult payload with' do
        let(:payload) { subscriber.payload_for(:failure).first }

        it 'a :success value of false' do
          expect(payload).not_to be_success
        end

        it 'an :errors field with the correct information' do
          message = 'Not logged in as a registered user!'
          expect(payload.errors.first).to be_an_error_hash_for :user, message
        end

        it 'an :entity value of nil' do
          expect(payload.entity).to be nil
        end
      end # describe 'is unsuccessful, broadcasting a StoreResult payload with'
    end # context 'for the Guest User'
  end # describe Actions::UpdatePost
end # module Actions