
require 'spec_helper'

require 'fancy-open-struct'

require 'wisper_subscription'

describe Newpoc::Action::Post::Update do
  let(:author) do
    FancyOpenStruct.new name: 'The Author', slug: 'the-author'
  end
  let(:guest_user) do
    FancyOpenStruct.new name: 'Guest User', slug: 'guest-user'
  end
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

      # rubocop:disable Lint/UnusedMethodArgument
      def update(identifier: _ident, updated_attrs: _attributes)
        @update_result
      end
      # rubocop:enable Lint/UnusedMethodArgument

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

  it 'has a version number' do
    expect(Newpoc::Action::Post::Update::VERSION).not_to be nil
  end

  context 'with the default success-event identifier, and' do
    let(:command) do
      described_class.new target_slug, post_data, current_user, post_repo,
                          guest_user
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

            it 'two key/value pairs' do
              expect(payload.size).to eq 2
            end

            it 'the post author name, using the :author_name key' do
              expect(payload[:author_name]).to eq author.name
            end

            it 'the current user name, using the :current_user_name key' do
              expect(payload[:current_user_name]).to eq current_user.name
            end
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
              Yajl.load input, symbolize_keys: true
            end

            it 'one key/value pair' do
              expect(payload.size).to eq 1
            end

            it 'the key :guest_access_prohibited' do
              expect(payload).to have_key :guest_access_prohibited
            end

            it 'a value of the requested article slug' do
              expect(payload[:guest_access_prohibited]).to eq target_slug
            end
          end # describe 'broadcasts :failure, with a JSON payload which...'
        end # context 'with no registered user logged in, it'
      end # context 'with valid post data, and'

      context 'with invalid post data, and' do
        let(:post_data) { FancyOpenStruct.new body: '', image_url: '' }

        context 'with the post author logged in, it' do
          let(:current_user) { author }
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

            it 'the specified slug' do
              expect(payload[:slug]).to eq target_slug
            end

            it 'the invalid input values rejected by the update attempt' do
              expect(payload[:inputs]).to eq post_data.to_h
            end
          end # describe 'broadcasts :failure, with a JSON payload which...'
        end # context 'with the post author logged in, it'
      end # context 'with invalid post data, and'
    end # context 'with a valid post slug as a search key, and'

    context 'with an invalid post slug as a search key, it' do
      let(:target_slug) { 'an invalid post slug' }
      let(:post_data) { valid_post_data }
      let(:current_user) { other_user }
      let(:repo_find_result) { repo_failure_result }
      let(:repo_update_result) { nil }

      it 'broadcasts :failure' do
        expect(subscriber).to be_failure
      end

      describe 'broadcasts failure, with a JSON payload which contains' do
        let(:payload) do
          input = subscriber.payload_for(:failure).first
          Yajl.load input, symbolize_keys: true
        end

        it 'one key/value pair' do
          expect(payload.size).to eq 1
        end

        it 'the key :slug_not_found' do
          expect(payload).to have_key :slug_not_found
        end

        it 'a value of the requested article slug' do
          expect(payload[:slug_not_found]).to eq target_slug
        end
      end # describe 'broadcasts failure, with a JSON payload which contains'
    end # context 'with an invalid post slug as a search key, it'
  end # context 'with the default success-event identifier, and'
end
