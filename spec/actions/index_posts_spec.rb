
require 'spec_helper'

require 'index_posts'

shared_examples 'a successful action' do |expected_drafts|

  describe 'is successful, broadcasting a payload which' do
    let(:payload) { subscriber.payload_for(:success).first }

    it 'is an Enumerable collection' do
      expect(payload).to be_an Enumerable
    end

    describe 'contains' do

      it 'all published posts' do
        expected_count = public_post_count + expected_drafts
        expect(payload).to have(expected_count).entries
        public_posts.each_with_index do |post, index|
          expect(payload[index]).to be_saved_post_entity_for post
        end
      end

      description = if expected_drafts == 0
                      'no draft posts'
                    else
                      'her own draft posts'
                    end
      it description do
        drafts = payload.select { |post| post.draft? }
        expect(drafts).to have(expected_drafts).entries
      end
    end # describe 'contains'
  end # describe 'is successful, broadcasting a payload which'
end # shared_examples 'a successful action'

### ######################################################################## ###
### ######################################################################## ###
### ######################################################################## ###
### ######################################################################## ###

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

      it_behaves_like 'a successful action', 0
    end # context 'for the Guest User'

    context 'for a Registered User' do

      before :each do
        command.subscribe subscriber
        command.execute
      end

      context 'who has authored draft posts' do
        let(:command) { klass.new author }

        it_behaves_like 'a successful action', 4
      end # context 'who has authored draft posts'

      context 'who has NOT authored draft posts' do
        let(:other_user) { FactoryGirl.create :user, :saved_user }
        let(:command) { klass.new other_user }

        it_behaves_like 'a successful action', 0
      end # context 'who has NOT authored draft posts'
    end # context 'for a Registered User'
  end # describe Actions::IndexPosts
end # module Actions
