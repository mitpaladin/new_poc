
require 'spec_helper'

describe PostsController::Responder::CreateFailure do
  let(:fake_controller) do
    Class.new do
      attr_reader :redirects, :renders, :root_path_calls, :post

      def initialize
        @redirects = []
        @renders = []
        @root_path_calls = []
      end

      def redirect_to(*args)
        @redirects.push args
        # don't care about faking a return value here
      end

      # def render(options = {}, locals = {}, &block)
      def render(*args)
        @renders.push args
        'rendered string'
      end

      def root_path(*args)
        @root_path_calls.push args
        root_path_literal
      end

      def root_path_literal
        '/'
      end
    end.new
  end

  describe 'initialisation' do
    context 'succeeds when passed a parameter that' do
      it 'implements the three required controller methods' do
        expect { described_class.new fake_controller }.not_to raise_error
      end
    end # context 'succeeds when passed a parameter that'
  end # describe 'initialisation'

  describe 'has a #respond_to method that' do
    let(:obj) { described_class.new fake_controller }
    before :each do
      obj.respond_to payload
    end

    context 'when reporting that there is no loggged-in user' do
      let(:payload) do
        data = { messages: [error_message] }
        RuntimeError.new YAML.dump(data)
      end
      let(:error_message) { 'Not logged in as a registered user!' }

      describe 'redirects' do
        let(:redirect) { fake_controller.redirects.first }
        let(:redirect_path) { redirect.first }
        let(:redirect_options) { redirect.last }

        it 'to the root path' do
          expect(redirect_path).to eq fake_controller.root_path_literal
        end

        it 'with the correct flash message' do
          expect(redirect_options).to have(1).value
          expect(redirect_options[:flash]).to eq(alert: error_message)
        end
      end # describe 'redirects'
    end # context 'when reporting that there is no loggged-in user'

    context 'when reporting that a Post is invalid' do
      let(:payload) do
        attrs = FactoryGirl.attributes_for :post, :saved_post, :published_post,
                                           author_name: nil
        RuntimeError.new JSON.dump(attrs)
      end

      describe 'indicates that the data was invalid by' do
        it 're-rendering the "new" template' do
          expect(fake_controller.renders.count).to eq 1
          expect(fake_controller.renders.first).to eq ['new']
        end

        describe 'assigning an invalid Post DAO instance' do
          it 'to the controller @post ivar' do
            expect(fake_controller.post).to be_a Repository::Post.new.dao
          end

          it 'that is invalid for the correct reason' do
            expect(fake_controller.post).not_to be_valid
            errors = fake_controller.post.errors
            expect(errors.full_messages.count).to eq 1
            expected = "Author name can't be blank"
            expect(errors.full_messages.first).to eq expected
          end
        end # describe 'assigning an invalid Post DAO instance'
      end # describe 'indicates that the data was invalid by'
    end # context 'when reporting that a Post is invalid'
  end # describe 'has a #respond_to method that
end # describe PostsController::Responder::CreateFailure
