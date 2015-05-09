
require 'spec_helper'

require_relative 'shared_examples/it_redirects'

describe PostsController::Responder::EditFailure do
  let(:fake_controller) do
    Class.new do
      attr_reader :redirects, :root_path_calls

      def initialize(current_user_name)
        @redirects = []
        @root_path_calls = []
        @current_user_name = current_user_name
      end

      def current_user
        FancyOpenStruct.new name: @current_user_name
      end

      def redirect_to(*args)
        @redirects.push args
        # don't care about faking a return value here
      end

      def root_path(*args)
        @root_path_calls.push args
        root_path_literal
      end

      def root_path_literal
        '/'
      end
    end.new(current_user_name)
  end

  describe 'initialisation' do
    context 'succeeds when passed a parameter that' do
      let(:current_user_name) { 'Just Anybody' }

      it 'implements the required controller methods' do
        expect { described_class.new fake_controller }.not_to raise_error
      end
    end # context 'succeeds when passed a parameter that'
  end # describe 'initialisation'

  describe 'has a #respond_to method that' do
    let(:obj) { described_class.new fake_controller }

    before :each do
      obj.respond_to payload
    end

    describe 'when reporting that' do
      let(:payload) { YAML.dump(messages: message) }

      context 'no user is logged in, it' do
        let(:current_user_name) { 'Guest User' }
        let(:message) { 'Not logged in as a registered user!' }

        it_behaves_like 'it redirects'
      end # context 'no user is logged in, it'

      context 'the current user is not the author, it' do
        let(:current_user_name) { 'John Doe' }
        let(:message) do
          "User #{current_user_name} is not the author of this post!"
        end
        let(:payload) { YAML.dump(messages: message) }

        it_behaves_like 'it redirects'
      end # context 'the current user is not the author, it'

      context 'the post is not valid, it' do
        let(:current_user_name) { post[:author_name] }
        let(:message) { 'Body must be specified if image URL is omitted' }
        let(:post) do
          FactoryGirl.attributes_for :post, :saved_post, :published_post,
                                     body: ''
        end
        let(:payload) { YAML.dump(post: post) }

        it_behaves_like 'it redirects'
      end # context 'the post is not valid, it'
    end # describe 'when reporting that'
  end # describe 'has a #respond_to method that'
end # describe PostsController::Responder::EditFailure
