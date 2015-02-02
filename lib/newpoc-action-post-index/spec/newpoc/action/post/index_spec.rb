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
        draft_count = payload.select { |post| !post.published? }.count
        expect(draft_count).to eq expected_drafts
      end
    end # describe 'contains'
  end # describe 'is successful, broadcasting a payload which'
end # shared_examples 'a successful action'

### ######################################################################## ###
### ######################################################################## ###
### ######################################################################## ###
### ######################################################################## ###

describe Newpoc::Action::Post::Index do
  let(:author_name) { 'The Author' }
  let(:draft_post_count) { 5 }
  let(:draft_posts) do
    draft_post_count.times.map do |n|
      FancyOpenStruct.new title: "Title #{n + first_draft_post_id}",
                          author_name: author_name,
                          :published? => false
    end
  end
  let(:first_draft_post_id) { published_post_count + 1 }
  let(:first_published_post_id) { 1 }
  let(:guest_user) { FancyOpenStruct.new name: 'Guest User' }
  let(:published_post_count) { 3 }
  let(:published_posts) do
    published_post_count.times.map do |n|
      FancyOpenStruct.new title: "Title #{n + first_published_post_id}",
                          author_name: author_name,
                          :published? => true
    end
  end
  let(:repo) { FancyOpenStruct.new all: [draft_posts, published_posts].flatten }
  let(:subscriber) { WisperSubscription.new }

  it 'has a version number' do
    expect(Newpoc::Action::Post::Index::VERSION).not_to be nil
  end

  context 'with default success-event identifier, it' do
    let(:command) { described_class.new guest_user, repo }

    before :each do
      subscriber.define_message :success
      command.subscribe subscriber
      command.execute
    end

    it 'is successful' do
      expect(subscriber).to be_success
    end

    context 'for the Guest User' do
      let(:command) { described_class.new guest_user, repo }

      it_behaves_like 'a successful action', 0
    end # context 'for the Guest User'

    context 'for a registered user' do
      let(:author_user) { FancyOpenStruct.new name: author_name }

      context 'who has authored draft posts' do
        let(:command) { described_class.new author_user, repo }

        it_behaves_like 'a successful action', 5 # draft_post_count
      end # context 'who has authored draft posts'

      context 'who has *not* authored draft posts' do
        let(:command) { described_class.new other_user, repo }
        let(:other_user) { FancyOpenStruct.new name: 'Somebody Else' }

        it_behaves_like 'a successful action', 0
      end # context 'who has *not* authored draft posts'
    end # context 'for a registered user'
  end # context 'with default success-event identifier, it'
end
