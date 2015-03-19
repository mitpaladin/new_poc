
require 'spec_helper'
require 'fancy-open-struct'
require 'support/broadcast_success_tester'
require 'wisper_subscription'

describe PostsController::Action::Update do
  let(:author) do
    FancyOpenStruct.new name: 'The Author', slug: 'the-author'
  end
  let(:guest_user) { UserFactory.guest_user }
  let(:other_user) do
    FancyOpenStruct.new name: 'J Random User', slug: 'j-random-user'
  end
  let(:post_repo) do
    Class.new do
      def initialize(find_result, update_result)
        @find_result = find_result
        @update_result = update_result
      end

      def find_by_slug(slug)
        @find_result if slug # should always be true; silences RuboCop :P
      end

      # def update(identifier: _ident, updated_attrs: _attributes)
      def update(*)
        @update_result
      end

      attr_accessor :returned_result
    end.new(repo_find_result, repo_update_result)
  end
  let(:post_slug) { 'post-slug' }
  let(:repo_failure_result) do
    FancyOpenStruct.new entity: nil, :success? => false
  end
  let(:repo_success_result) do
    FancyOpenStruct.new entity: repo_success_entity, :success? => true
  end
  let(:subscriber) { WisperSubscription.new }
  let(:valid_post_data) do
    ret = FancyOpenStruct.new image_url: image_url, body: post_body
    ret.class.send(:define_method, :valid?) do
      true
    end
    ret
  end
  let(:post_body) { 'This is the post body after updating.' }
  let(:image_url) { 'http://www.example.com/image794.png' }
  let(:command) do
    described_class.new slug: target_slug, post_data: post_data,
                        current_user: current_user, repository: post_repo
  end

  before :each do
    subscriber.define_message :success
    subscriber.define_message :failure
    command.subscribe subscriber
    command.execute
  end

  context 'with a valid post slug as a search key, and' do
    let(:target_slug) { post_slug }
    let(:repo_success_entity) do
      FancyOpenStruct.new author_name: author.name,
                          :valid? => true,
                          attributes: { author_name: author.name }
    end

    context 'with valid post data, and' do
      let(:post_data) { valid_post_data }

      context 'with the post author logged in, it' do
        let(:current_user) { author }
        let(:repo_find_result) { repo_success_result }
        let(:repo_update_result) { repo_success_result }

        it 'broadcasts :success' do
          expect(subscriber).to be_success
        end

        describe 'broadcasts :success with a payload which' do
          let(:payload) { subscriber.payload_for(:success).first }

          it 'is the requested (post) entity' do
            expect(payload).to eq repo_success_entity
          end
        end # describe 'broadcasts :success with a payload which'
      end # context 'with the post author logged in, it'

      context 'with a different registered user logged in, it' do
        let(:current_user) { other_user }
        let(:repo_find_result) { repo_success_result }
        let(:repo_update_result) { repo_failure_result }

        it 'broadcasts :failure' do
          expect(subscriber).to be_failure
        end

        describe 'broadcasts :failure, with a JSON payload which contains' do
          let(:payload) do
            input = subscriber.payload_for(:failure).first
            Yajl.load input, symbolize_keys: true
          end

          it 'two top-level entries, :current_user_name and :post' do
            expect(payload.keys).to eq [:current_user_name, :post]
          end

          it 'the current user name, using the :current_user_name key' do
            expect(payload[:current_user_name]).to eq current_user.name
          end

          describe 'information about the post, including' do
            let(:post_payload) { payload[:post] }

            it 'the author name' do
              expect(post_payload[:author_name]).to eq author.name
            end
          end # describe 'information about the post, including'
        end # describe 'broadcasts :failure, with a JSON payload which...'
      end # context 'with a different registered user logged in, it'

      context 'with no registered user logged in, it' do
        let(:current_user) { guest_user }
        let(:repo_find_result) { repo_success_result }
        let(:repo_update_result) { repo_failure_result }

        it 'broadcasts :failure' do
          expect(subscriber).to be_failure
        end

        describe 'broadcasts :failure, with a JSON payload which contains' do
          let(:payload) do
            input = subscriber.payload_for(:failure).first
            YAML.load input
          end

          it 'one key/value pair' do
            expect(payload.size).to eq 1
          end

          it 'the key :messages' do
            expect(payload).to have_key :messages
          end

          it 'an error message stating that no user is logged in' do
            expected = 'Not logged in as a registered user!'
            expect(payload[:messages].first).to eq expected
          end
        end # describe 'broadcasts :failure, with a JSON payload which...'
      end # context 'with no registered user logged in, it'
    end # context 'with valid post data, and'
  end # context 'with a valid post slug as a search key, and'
end # describe PostsController::Action::Update
