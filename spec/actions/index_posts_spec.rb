
require 'spec_helper'

require 'index_posts'

shared_examples 'a successful StoreResult payload' do
  it 'a :success field of true' do
    expect(payload).to be_success
  end

  it 'an empty :errors collection' do
    expect(payload.errors).to be_empty
  end
end

# Short and sweet. There are presently no failure cases defined.

module Actions
  describe IndexPosts do
    let(:klass) { IndexPosts }
    let(:subscriber) { BroadcastSuccessTester.new }
    # let(:command) { klass.new current_user }
    let(:author) { FactoryGirl.create :user, :saved_user }
    let(:guest_user) { UserRepository.new.guest_user.entity }
    let(:public_post_count) { 6 }
    let(:draft_post_count) { 4 }
    let(:draft_posts) do
      FactoryGirl.create_list :post, draft_post_count, :saved_post,
                              author_name: author.name
    end
    let!(:public_posts) do
      FactoryGirl.create_list :post, public_post_count, :saved_post,
                              :published_post
    end
    # let(:command) { klass.new current_user }

    before :each do
      # Why not just use `let!`? This can be updated/moved as needed without
      # touching the deinitions, that's why.
      _ = [public_posts, draft_posts]
    end

    it 'is successful' do
      command = klass.new guest_user
      command.subscribe subscriber
      command.execute
      expect(subscriber).to be_successful
      expect(subscriber).not_to be_failure
    end

    context 'for the Guest User' do
      let(:command) { klass.new guest_user }

      before :each do
        command.subscribe subscriber
        command.execute
      end

      describe 'is successful, broadcasting a StoreResult payload with' do
        let(:payload) { subscriber.payload_for(:success).first }

        it_behaves_like 'a successful StoreResult payload'

        describe 'an :entity which is a collection containing' do

          it 'all published posts' do
            expect(payload.entity).to have(public_post_count).entries
            public_posts.each_with_index do |post, index|
              expect(payload.entity[index]).to be_saved_post_entity_for post
            end
          end

          it 'no draft posts' do
            drafts = payload.entity.select { |post| post.pubdate.nil? }
            expect(drafts).to be_empty
          end
        end # describe 'an :entity which is a collection containing'
      end # describe 'is successful, broadcasting a StoreResult payload with'
    end # context 'for the Guest User'

    context 'for a Registered User' do

      before :each do
        command.subscribe subscriber
        command.execute
      end

      context 'who has authored draft posts' do
        let(:command) { klass.new author }

        describe 'is successful, broadcasting a StoreResult payload with' do
          let(:payload) { subscriber.payload_for(:success).first }

          it_behaves_like 'a successful StoreResult payload'

          describe 'an :entity which is a collection containing' do
            it 'all published posts' do
              public_posts.each_with_index do |post, index|
                expect(payload.entity[index]).to be_saved_post_entity_for post
              end
            end

            it 'her own draft posts' do
              draft_posts.each_with_index do |post, draft_index|
                index = draft_index + public_post_count
                expect(payload.entity[index]).to be_saved_post_entity_for post
              end
            end
          end # describe 'an :entity which is a collection containing'
        end # describe 'is successful, broadcasting a StoreResult payload with'
      end # context 'who has authored draft posts'

      context 'who has NOT authored draft posts' do
        let(:other_user) { FactoryGirl.create :user, :saved_user }
        let(:command) { klass.new other_user }

        describe 'is successful, broadcasting a StoreResult payload with' do
          let(:payload) { subscriber.payload_for(:success).first }

          it_behaves_like 'a successful StoreResult payload'

          describe 'an :entity which is a collection containing' do

            it 'all published posts' do
              expect(payload.entity).to have(public_post_count).entries
              public_posts.each_with_index do |post, index|
                expect(payload.entity[index]).to be_saved_post_entity_for post
              end
            end

            it 'no draft posts' do
              drafts = payload.entity.select { |post| post.pubdate.nil? }
              expect(drafts).to be_empty
            end
          end # describe 'an :entity which is a collection containing'
        end # describe 'is successful, broadcasting a StoreResult payload with'
      end # context 'who has NOT authored draft posts'
    end # context 'for a Registered User'
  end # describe Actions::IndexPosts
end # module Actions
