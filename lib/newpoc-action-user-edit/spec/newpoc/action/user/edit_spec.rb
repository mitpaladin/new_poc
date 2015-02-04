
require 'spec_helper'

require 'fancy-open-struct'
require 'wisper_subscription'

describe Newpoc::Action::User::Edit do
  let(:user_repo) do
    Class.new do
      def initialize(returned_result)
        @returned_result = returned_result
      end

      def find_by_slug(slug)
        @returned_result if slug # should always be true; silences RuboCop :P
      end
    end.new(result)
  end
  let(:current_user) { FancyOpenStruct.new slug: target_slug }
  let(:result) do
    FancyOpenStruct.new entity: the_entity, :success? => result_success
  end
  let(:subscriber) { WisperSubscription.new }
  let(:success_entity) { FancyOpenStruct.new slug: target_slug }
  let(:target_slug) { 'target_slug' }

  it 'has a version number' do
    expect(Newpoc::Action::User::Edit::VERSION).not_to be nil
  end

  context 'with default option settings' do
    let(:command) do
      described_class.new current_user, user_repo
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
      let(:result_success) { false }
      let(:the_entity) { nil }

      it 'broadcasts :failure' do
        expect(subscriber).to be_failure
      end

      describe 'broadcasts :failure with a payload which' do
        let(:payload) { subscriber.payload_for(:failure).first }

        it 'is the original target slug' do
          expect(payload).to eq target_slug
        end
      end # describe 'broadcasts :success with a payload which'
    end # context 'when the repository query is unsuccessful'
  end # context 'with default option settings'

  context 'with non-default option settings' do
    let(:command) do
      described_class.new current_user, user_repo, options
    end
    let(:options) { { success: :message_one, failure: :message_two } }

    before :each do
      subscriber.define_message :message_one
      subscriber.define_message :message_two
      subscriber.define_message :success
      subscriber.define_message :failure
      command.subscribe subscriber
      command.execute
    end

    context 'when the repository query is successful' do
      let(:result_success) { true }
      let(:the_entity) { success_entity }

      it 'broadcasts the specified event for success' do
        expect(subscriber).to be_message_one
      end

      it 'does not broadcast the default :success event' do
        expect(subscriber).not_to be_success
      end
    end # context 'when the repository query is successful'

    context 'when the repository query is unsuccessful' do
      let(:result_success) { false }
      let(:the_entity) { nil }

      it 'broadcasts the specified event for failure' do
        expect(subscriber).to be_message_two
      end

      it 'does not broadcast the default :failure event' do
        expect(subscriber).not_to be_failure
      end
    end # context 'when the repository query is unsuccessful'
  end # context 'with non-default option settings'
end
