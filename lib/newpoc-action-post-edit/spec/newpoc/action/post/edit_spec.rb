
require 'spec_helper'

require 'fancy-open-struct'

require 'wisper_subscription'

describe Newpoc::Action::Post::Edit do
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

  it 'has a version number' do
    expect(Newpoc::Action::Post::Edit::VERSION).not_to be nil
  end

  context 'with the default success-event identifier, and' do
    let(:command) do
      described_class.new target_slug, current_user, post_repo, guest_user
    end

    before :each do
      subscriber.define_message :success
      subscriber.define_message :failure
      command.subscribe subscriber
      command.execute
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

          describe 'is the expected error data, which' do
            let(:error_data) { Yajl.load payload, symbolize_keys: true }

            it 'is Hash-like' do
              expect(error_data).to respond_to :to_hash
            end

            it 'has the single key value of :guest_access_prohibited' do
              expect(error_data.keys).to eq [:guest_access_prohibited]
            end

            it 'has the correct single data value of the post slug' do
              expect(error_data[:guest_access_prohibited]).to eq post_slug
            end
          end # describe 'is the expected error data, which'
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

        describe 'broadcasts :failure with a payload which' do
          let(:payload) { subscriber.payload_for(:failure).first }

          describe 'is the expected error data, which' do
            let(:error_data) { Yajl.load payload, symbolize_keys: true }

            it 'is Hash-like' do
              expect(error_data).to respond_to :to_hash
            end

            description = 'reports the current user name using the' \
              ' :current_user_name key'
            it description do
              expect(error_data[:current_user_name]).to eq current_user.name
            end

            it 'reports the post author name using the :author_name key' do
              expected = repo_success_entity.author_name
              expect(error_data[:author_name]).to eq expected
            end
          end # describe 'is the expected error data, which'
        end # describe 'broadcasts :failure with a payload which'
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
            let(:error_data) { Yajl.load payload, symbolize_keys: true }

            it 'is Hash-like' do
              expect(error_data).to respond_to :to_hash
            end

            it 'contains one item' do
              expect(error_data.count).to eq 1
            end

            it 'has the item key :guest_access_prohibited' do
              expect(error_data).to have_key :guest_access_prohibited
            end

            it 'has the item value as the target slug' do
              expect(error_data).to have_value target_slug
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
            let(:error_data) { Yajl.load payload, symbolize_keys: true }

            it 'is Hash-like' do
              expect(error_data).to respond_to :to_hash
            end

            it 'contains a single key/value pair' do
              expect(error_data.keys.count).to eq 1
            end

            it 'has an item with the key :slug_not_found' do
              expect(error_data.keys).to eq [:slug_not_found]
            end

            it 'has the target slug as the value for the single item' do
              expect(error_data[:slug_not_found]).to eq target_slug
            end
          end # describe 'is the expected error data, which'
        end # describe 'broadcasts :failure with a payload which'
      end # context 'with a user other than the author logged in' do
    end # context 'with an invalid post slug as a search key, and'
  end # context 'with the default success-event identifier, and'

  context 'with non-default success-event identifiers' do
    let(:command) do
      opts = { success: :message_one, failure: :message_two }
      described_class.new target_slug, current_user, post_repo, guest_user, opts
    end
    let(:target_slug) { post_slug }

    before :each do
      subscriber.define_message :success
      subscriber.define_message :failure
      subscriber.define_message :message_one
      subscriber.define_message :message_two
      command.subscribe subscriber
      command.execute
    end

    context 'when reporting a successful result, it' do
      let(:current_user) { author }
      let(:repo_result) { repo_success_result }

      it 'broadcasts the specified success event' do
        expect(subscriber.message_one?).to be true
      end

      it 'does not broadcast the default :success event' do
        expect(subscriber).not_to be_success
      end
    end # context 'when reporting a successful result, it'

    context 'when reporting an unsuccessful result, it' do
      let(:current_user) { guest_user }
      let(:repo_result) { repo_failure_result }

      it 'broadcasts the specified failure event' do
        expect(subscriber.message_two?).to be true
      end

      it 'does not broadcast the default :failure event' do
        expect(subscriber).not_to be_failure
      end
    end # context 'when reporting an unsuccessful result, it'
  end # context 'with non-default success-event identifiers'
end
