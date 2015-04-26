
require 'spec_helper'

describe PostsController::Responder::NewFailure do
  let(:fake_controller) do
    Class.new do
      attr_reader :redirects, :root_path_calls

      def initialize
        @redirects = []
        @root_path_calls = []
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
    end.new
  end

  describe 'initialisation' do
    context 'succeeds when passed a parameter that' do
      it 'implements the required controller methods' do
        expect { described_class.new fake_controller }.not_to raise_error
      end
    end # context 'succeeds when passed a parameter that'
  end # describe 'initialisation'

  describe 'has a #respond_to method that' do
    let(:obj) { described_class.new fake_controller }
    let(:payload) { 'Some error message would go here. Or something.' }

    before :each do
      obj.respond_to payload
    end

    describe 'redirects' do
      let(:redirect) { fake_controller.redirects.first }
      let(:redirect_path) { redirect.first }
      let(:redirect_options) { redirect.last }

      it 'to the root path' do
        expect(redirect_path).to eq fake_controller.root_path_literal
      end

      it 'with the correct flash message' do
        expect(redirect_options).to have(1).value
        expect(redirect_options[:flash]).to eq(alert: payload)
      end
    end # describe 'redirects'
  end # describe 'has a #respond_to method that'
end # describe PostsController::Responder::NewFailure
