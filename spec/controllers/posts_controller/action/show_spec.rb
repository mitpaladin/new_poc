
require 'spec_helper'
require 'current_user_identity'
require 'support/broadcast_success_tester'

describe PostsController::Action::Show do
  let(:command) do
    described_class.new current_user: current_user, repository: post_repository,
                        target_slug: target_slug
  end
  let(:current_user) do
    FactoryGirl.build_stubbed :user, :saved_user, name: user_name
  end
  let(:post_repository) do
    Class.new do
      def initialize(returned_result)
        @returned_result = returned_result
      end

      def find_by_slug(slug)
        @returned_result if slug # should always be true; silences RuboCop :P
      end
    end.new(result)
  end
  let(:result) do
    FancyOpenStruct.new entity: the_entity, success?: result_success
  end
  let(:subscriber) { WisperSubscription.new }
  let(:success_entity) do
    attribs = FactoryGirl.attributes_for :post, :saved_post,
                                         author_name: entity_author_name
    PostFactory.create attribs
  end
  let(:target_slug) { 'some-slug' }
  let(:user_name) { 'Just Anybody' }

  before :each do
    subscriber.define_message :success
    subscriber.define_message :failure
    command.subscribe subscriber
    command.execute
  end

  context 'when the repository query is successful,' do
    let(:entity_author_name) { user_name }
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
  end # context 'when the repository query is successful,'

  context 'when the repository query is unsuccessful,' do
    let(:entity_author_name) { 'somebody else' }
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
  end # context 'when the repository query is unsuccessful,'
end # describe PostsController::Action::New
