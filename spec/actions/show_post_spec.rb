
require 'spec_helper'

require 'show_post'

require_relative 'shared_examples/a_successfully_retrieved_post'

module Actions
  describe ShowPost do
    let(:author) do
      attribs = FactoryGirl.attributes_for :user, :saved_user
      UserEntity.new(attribs).tap { |user| UserRepository.new.add user }
    end
    let(:command) { described_class.new target_post.slug, current_user }
    let(:guest_user) { UserRepository.new.guest_user.entity }
    let(:repo) { PostRepository.new }
    let(:subscriber) { BroadcastSuccessTester.new }
    let(:target_post) do
      Newpoc::Entity::Post.new(target_attribs).tap { |post| repo.add post }
    end

    before :each do
      command.subscribe(subscriber).execute
    end

    context 'for an existing published post' do
      let(:current_user) { guest_user }
      let(:target_attribs) do
        FactoryGirl.attributes_for :post, :saved_post, :published_post
      end

      it_behaves_like 'a successfully-retrieved post'
    end # context 'for an existing published post' do

    context 'for an existing draft post' do
      let(:target_attribs) do
        FactoryGirl.attributes_for :post, :saved_post, author_name: author.name
      end

      context 'being viewed by the post author' do
        let(:current_user) { author }

        it_behaves_like 'a successfully-retrieved post'
      end # context 'being viewed by the post author'

      context 'being viewed by anyone else' do
        let(:current_user) { guest_user }

        it 'is unsuccessful' do
          expect(subscriber).not_to be_successful
          expect(subscriber).to be_failure
        end

        describe 'is unsuccessful, broadcasting an error message' do
          let(:payload) { subscriber.payload_for(:failure).first }

          it 'that contains the required text' do
            message = 'Cannot find post identified by slug:' \
              " '#{target_post.slug}'!"
            expect(payload).to eq message
          end
        end # describe 'is unsuccessful, broadcasting an error message'
      end # context 'being viewed by anyone else'
    end # context 'for an existing draft post'
  end # describe Actions::ShowPost
end # module Actions
