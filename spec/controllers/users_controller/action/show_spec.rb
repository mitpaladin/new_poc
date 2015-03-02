
require 'spec_helper'

require 'fancy-open-struct'
require 'wisper_subscription'

describe UsersController::Action::Show do
  let(:command) do
    described_class.new target_slug: target_slug, user_repository: user_repo
  end
  let(:result) do
    FancyOpenStruct.new :entity => the_entity, :success? => result_success
  end
  let(:subscriber) { WisperSubscription.new }
  let(:success_entity) { 'THE ENTITY' }
  let(:target_slug) { 'Some User' }
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
    let(:result_success) { false }
    let(:the_entity) { nil }

    it 'broadcasts :failure' do
      expect(subscriber).to be_failure
    end

    describe 'broadcasts :failure with a payload which' do
      let(:payload) { subscriber.payload_for(:failure).first }

      it 'is the original slug' do
        expect(payload).to eq target_slug
      end
    end # describe 'broadcasts :failure with a payload which'
  end # context 'when the repository query is unsuccessful, it'
end # describe UsersController::Action::Show
