
require 'spec_helper'
require 'fancy-open-struct'
require 'current_user_identity'
require 'support/broadcast_success_tester'

describe PostsController::Action::Edit do
  let(:author) do
    FancyOpenStruct.new name: 'The Author', slug: 'the-author'
  end
  let(:command) do
    described_class.new slug: target_slug, current_user: current_user,
                        repository: post_repo
  end
  let(:guest_user) { UserFactory.guest_user }
  let(:other_user) do
    FancyOpenStruct.new name: 'J Random User', slug: 'j-random-user'
  end
  let(:post_repo) do
    Class.new do
      def initialize(returned_result)
        @returned_result = returned_result
      end

      def find_by_slug(slug)
        @returned_result if slug # should always be true; silences RuboCop :P
      end
    end.new(repo_result)
  end
  let(:post_slug) { 'post-slug' }
  let(:repo_failure_result) do
    FancyOpenStruct.new entity: nil, :success? => false
  end
  let(:repo_success_result) do
    FancyOpenStruct.new entity: repo_success_entity, :success? => true
  end
  let(:subscriber) { WisperSubscription.new }
  let(:repo_success_entity) do
    FancyOpenStruct.new author_name: author.name
  end

  before :each do
    subscriber.define_message :success
    subscriber.define_message :failure
    command.subscribe(subscriber).execute
  end

  context 'with a valid post slug as a search key, and' do
    let(:target_slug) { post_slug }

    context 'with no currently logged-in user, it' do
      let(:current_user) { guest_user }
      let(:repo_result) { repo_failure_result }

      it 'broadcasts :failure' do
        expect(subscriber).to be_failure
      end

      describe 'broadcasts :failure with a payload which' do
        let(:payload) { subscriber.payload_for(:failure).first }

        it 'is the correct error message' do
          expect(payload).to eq 'Not logged in as a registered user!'
        end
      end # describe 'broadcasts :failure with a payload which'
    end # context 'with no currently logged-in user, it'

    context 'with the post author logged in, it' do
      let(:current_user) { author }
      let(:repo_result) { repo_success_result }

      it 'broadcasts :success' do
        expect(subscriber).to be_success
      end

      describe 'broadcasts :success with a payload which' do
        let(:payload) { subscriber.payload_for(:success).first }

        it 'is the requested entity' do
          expect(payload).to eq repo_success_entity
        end
      end # describe 'broadcasts :success with a payload which'
    end # context 'with the post author logged in, it'

    context 'with a user other than the author logged in, it' do
      let(:current_user) { other_user }
      let(:repo_result) { repo_success_result }

      it 'broadcasts failure' do
        expect(subscriber).to be_failure
      end

      it 'broadcasts failure with the correct error message' do
        payload = subscriber.payload_for(:failure).first
        parts = ['User ', ' is not the author of this post!']
        expect(payload).to eq parts.join(current_user.name)
      end
    end # context 'with a user other than the author logged in, it' do
  end # context 'with a valid post slug as a search key, and'

  context 'with an invalid post slug as a search key, and' do
    let(:repo_result) { repo_failure_result }
    let(:target_slug) { 'this is a bogus slug' }
    # If there's no article, there's no author *for* that article.

    context 'with no currently logged-in user' do
      let(:current_user) { guest_user }

      it 'broadcasts :failure' do
        expect(subscriber).to be_failure
      end

      describe 'broadcasts :failure with a payload which' do
        let(:payload) { subscriber.payload_for(:failure).first }

        describe 'is the expected error data, which' do
          let(:error_data) { YAML.load payload }

          it 'is the correct error message' do
            expect(payload).to eq 'Not logged in as a registered user!'
          end
        end # describe 'is the expected error data, which'
      end # describe 'broadcasts :failure with a payload which'
    end # context 'with no currently logged-in user'

    context 'with a user other than the author logged in' do
      let(:current_user) { other_user }

      it 'broadcasts :failure' do
        expect(subscriber).to be_failure
      end

      describe 'broadcasts :failure with a payload which' do
        let(:payload) { subscriber.payload_for(:failure).first }

        describe 'is the expected error data, which' do
          let(:error_data) { YAML.load payload }

          it 'contains the key "slug" and the invalid slug in a Hash' do
            expected = { 'slug' => target_slug }
            expect(error_data).to eq expected
          end
        end # describe 'is the expected error data, which'
      end # describe 'broadcasts :failure with a payload which'
    end # context 'with a user other than the author logged in' do
  end # context 'with an invalid post slug as a search key, and'
end # describe PostsController::Action::Edit
