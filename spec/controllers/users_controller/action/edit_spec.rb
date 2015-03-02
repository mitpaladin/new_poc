
require 'spec_helper'

require 'fancy-open-struct'
require 'wisper_subscription'

describe UsersController::Action::Edit do
  let(:command) do
    described_class.new slug: target_slug, current_user: current_user,
                        user_repository: user_repository
  end
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

  before :each do
    subscriber.define_message :success
    subscriber.define_message :failure
    command.subscribe(subscriber).execute
  end

  context 'when the repository query is successful, it' do
    let(:result_success) { true }
    let(:the_entity) { success_entity }

    it 'broadcasts success' do
      expect(subscriber).to be_success
    end

    describe 'broadcasts :success with a payload which' do
      let(:payload) { subscriber.payload_for(:success).first }

      it 'is the expected entity' do
        expect(payload).to eq success_entity
      end
    end # describe 'broadcasts :success with a payload which'
  end # context 'when the repository query is successful, it'

  context 'when the repository query is unsuccessful, it' do
    context 'because the user is not found' do
      let(:result_success) { false }
      let(:the_entity) { nil }

      it 'broadcasts :failure' do
        expect(subscriber).to be_failure
      end

      describe 'broadcasts :failure with a payload which' do
        let(:payload) { subscriber.payload_for(:failure).first }

        it 'is a Hash containing the original target slug' do
          expected = { slug: target_slug }
          expect(payload).to eq expected
        end
      end # describe 'broadcasts :failure with a payload which'
    end # context 'because the user is not found'

    context 'because the current user does not match the requested user, it' do
      let(:result_success) { true }
      let(:the_entity) { success_entity }
      let(:current_user_name) { 'Jim Bogus' }
      let(:current_user_slug) { 'jim-bogus' }

      it 'broadcasts :failure' do
        expect(subscriber).to be_failure
      end

      describe 'broadcasts :failure with a payload which' do
        let(:payload) { subscriber.payload_for(:failure).first }

        fit 'is a Hash containing the current and target user names' do
          expect(payload).to respond_to :to_hash
          expect(payload.keys.count).to eq 2
          expect(payload[:current]).to eq current_user_name
          ap payload
          expect(payload[:not_user]).to eq success_entity.name
        end
      end # describe 'broadcasts :success with a payload which'
    end # context 'because the ... user does not match the requested user, it'
  end # context 'when the repository query is unsuccessful, it'
end
