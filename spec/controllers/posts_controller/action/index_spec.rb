
require 'spec_helper'

require 'fancy-open-struct'
require 'wisper_subscription'

shared_examples 'a successful action' do |expected_drafts|
  describe 'is successful, broadcasting a payload which' do
    let(:payload) { subscriber.payload_for(:success).first }

    it 'is an Enumerable collection' do
      expect(payload).to be_an Enumerable
    end

    describe 'contains' do
      it 'all published posts' do
        expected_count = published_post_count + expected_drafts
        expect(payload.count).to eq expected_count
        published_posts.each_with_index do |post, _index|
          expect(payload).to include post
        end
      end

      description = if expected_drafts == 0
                      'no draft posts'
                    else
                      'current user\'s own draft posts'
                    end
      it description do
        drafts = payload.select { |post| !post.published? }
        expect(drafts.count).to eq expected_drafts
      end
    end # describe 'contains'
  end # describe 'is successful, broadcasting a payload which'
end # shared_examples 'a successful action'

### ######################################################################## ###
### ######################################################################## ###
### ######################################################################## ###
### ######################################################################## ###

describe PostsController::Action::Index do
  let(:author_name) { 'The Author' }
  let(:command) do
    described_class.new current_user: current_user, post_repository: repo
  end
  let(:current_user) { guest_user }
  let(:draft_post_count) { 5 }
  let(:draft_posts) do
    draft_post_count.times.map do |n|
      new_attribs = {
        title: "Title #{n + first_draft_post_id}",
        author_name: author_name
      }
      attribs = FactoryGirl.attributes_for :post, new_attribs
      Entity::Post.new attribs
    end
  end
  let(:first_draft_post_id) { published_post_count + 1 }
  let(:first_published_post_id) { 1 }
  let(:guest_user) { UserDao.first }
  let(:published_post_count) { 3 }
  let(:published_posts) do
    published_post_count.times.map do |n|
      new_attribs = {
        title: "Title #{n + first_published_post_id}",
        author_name: author_name
      }
      attribs = FactoryGirl.attributes_for :post, :published_post, new_attribs
      Entity::Post.new attribs
    end
  end
  let(:repo) { FancyOpenStruct.new all: [draft_posts, published_posts].flatten }
  let(:subscriber) { WisperSubscription.new }

  before :each do
    subscriber.define_message :success
    command.subscribe subscriber
    command.execute
  end

  it 'is successful' do
    expect(subscriber).to be_success
  end

  context 'for the Guest User' do
    let(:current_user) { guest_user }

    it_behaves_like 'a successful action', 0
  end # context 'for the Guest User'

  context 'for a registered user' do
    let(:author_user) do
      FactoryGirl.build_stubbed :user, name: author_name
    end

    context 'who has authored draft posts' do
      let(:current_user) { author_user }

      it_behaves_like 'a successful action', 5 # draft_post_count
    end # context 'who has authored draft posts'

    context 'who has *not* authored draft posts' do
      let(:current_user) { other_user }
      let(:other_user) do
        FactoryGirl.build_stubbed :user, :saved_user, name: 'Somebody Else'
      end

      it_behaves_like 'a successful action', 0
    end # context 'who has *not* authored draft posts'
  end # context 'for a registered user'
end # describe PostsController::Action::Index
