
require 'spec_helper'

require 'fancy-open-struct'
require 'wisper_subscription'

describe Newpoc::Action::User::Edit do
  let(:current_user) do
    FancyOpenStruct.new name: current_user_name, slug: current_user_slug
  end
  let(:current_user_name) { user_name }
  let(:current_user_slug) { target_slug }
  let(:result) do
    FancyOpenStruct.new entity: the_entity, :success? => result_success
  end
  let(:subscriber) { WisperSubscription.new }
  let(:success_entity) do
    FancyOpenStruct.new name: user_name, slug: target_slug
  end
  let(:target_slug) { 'just-anybody' }
  let(:user_name) { 'Just Anybody' }
  let(:user_repository) do
    Class.new do
      def initialize(returned_result)
        @returned_result = returned_result
      end

      def find_by_slug(slug)
        @returned_result if slug # should always be true; silences RuboCop :P
      end
    end.new(result)
  end

  it 'has a version number' do
    expect(Newpoc::Action::User::Edit::VERSION).not_to be nil
  end

  context 'with default option settings' do
    let(:command) do
      described_class.new target_slug, current_user, user_repository
    end

    before :each do
      subscriber.define_message :success
      subscriber.define_message :failure
      command.subscribe subscriber
      command.execute
    end

    context 'when the repository query is successful' do
      let(:result_success) { true }
      let(:the_entity) { success_entity }

      it 'broadcasts :success' do
        expect(subscriber).to be_success
      end

      describe 'broadcasts :success with a payload which' do
        let(:payload) { subscriber.payload_for(:success).first }

        it 'is the expected entity' do
          expect(payload).to eq success_entity
        end
      end # describe 'broadcasts :success with a payload which'
    end # context 'when the repository query is successful'

    context 'when the repository query is unsuccessful' do
      context 'because the user is not found' do
        let(:result_success) { false }
        let(:the_entity) { nil }

        it 'broadcasts :failure' do
          expect(subscriber).to be_failure
        end

        describe 'broadcasts :failure with a payload which' do
          let(:payload) { subscriber.payload_for(:failure).first }

          it 'is a hash containing the original target slug' do
            expect(payload).to respond_to :to_hash
            expect(payload.keys.count).to eq 1
            expect(payload[:slug]).to eq target_slug
          end
        end # describe 'broadcasts :success with a payload which'
      end # context 'because the user is not found'

      context 'because the current user does not match the requested user' do
        let(:result_success) { true }
        let(:the_entity) { success_entity }
        let(:current_user_name) { 'Jim Bogus' }
        let(:current_user_slug) { 'jim-bogus' }

        it 'broadcasts :failure' do
          expect(subscriber).to be_failure
        end

        describe 'broadcasts :failure with a payload which' do
          let(:payload) { subscriber.payload_for(:failure).first }

          it 'is a Hash containing the current and target user names' do
            expect(payload).to respond_to :to_hash
            expect(payload.keys.count).to eq 2
            expect(payload[:current]).to eq current_user_name
            expect(payload[:not_user]).to eq success_entity.name
          end
        end # describe 'broadcasts :success with a payload which'
      end # context 'because the current user does not match the requested user'
    end # context 'when the repository query is unsuccessful'
  end # context 'with default option settings'

  context 'with non-default option settings' do
    let(:command) do
      described_class.new target_slug, current_user, user_repository, options
    end
    let(:options) { { success: :message_one, failure: :message_two } }

    before :each do
      subscriber.define_message :success
      subscriber.define_message :failure
      subscriber.define_message :message_one
      subscriber.define_message :message_two
      command.subscribe subscriber
      command.execute
    end

    context 'when the repository query is successful' do
      let(:result_success) { true }
      let(:the_entity) { success_entity }

      it 'broadcasts the specified event for success' do
        expect(subscriber.message_one?).to be true
      end

      it 'does not broadcast the defcault :success event' do
        expect(subscriber).not_to be_success
      end
    end # context 'when the repository query is successful'

    context 'when the repository query is unsuccessful' do
      let(:result_success) { false }
      let(:the_entity) { nil }

      it 'broadcasts the specified event for failure' do
        expect(subscriber.message_two?).to be true
      end

      it 'does not broadcast the defcault :failure event' do
        expect(subscriber).not_to be_failure
      end
    end # context 'when the repository query is unsuccessful'
  end # context 'with non-default option settings'
end
