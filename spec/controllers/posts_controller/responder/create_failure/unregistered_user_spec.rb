
require 'spec_helper'

target_class = PostsController::Responder::CreateFailure::UnregisteredUser
describe target_class, type: :request do
  let(:fake_controller) do
    Class.new do
      attr_reader :redirects, :renders, :root_path_calls, :post

      def initialize
        @redirects = []
        @root_path_calls = []
      end

      def redirect_to(*args)
        @redirects.push args
        # don't care about faking a return value here
      end

      def root_path(*_args)
        @root_path_calls.push :called
        root_path_literal
      end

      def root_path_literal
        '/'
      end
    end.new
  end

  describe 'has initialisation that' do
    describe 'accepts a Hash-like object as a parameter' do
      it 'with entries keyed as "redirect_to" and "root_path"' do
        h = {}
        h.store 'redirect_to', fake_controller.method(:redirect_to)
        h.store 'root_path', fake_controller.method(:root_path)
        expect { described_class.new h }.not_to raise_error
      end
    end # describe 'accepts a Hash-like object as a parameter'
  end # describe 'has initialisation that'

  describe 'has an .applies? class method that' do
    describe 'returns false when passed in something that is' do
      it 'not a RuntimeError or other such error' do
        expect(described_class.applies? :bogus).to be false
      end

      it 'a RuntimeError with an invalid payload in its message' do
        data = { anything: false }
        payload = RuntimeError.new YAML.dump(data)
        expect(described_class.applies? payload).to be false
      end
    end # describe 'returns false when passed in something that is'

    describe 'returns true when passed in a RuntimeError whose message' do
      context 'contains a YAML-encoded Hash with key :messages and' do
        it 'a value of an array including the no-user-logged-in message' do
          data = { messages: ['Not logged in as a registered user!'] }
          payload = RuntimeError.new YAML.dump(data)
          expect(described_class.applies? payload).to be true
        end
      end # context 'contains a YAML-encoded Hash with key :messages and'
    end # describe 'returns true when passed in a RuntimeError whose message'
  end # describe 'has an .applies? class method that'

  describe 'has a #call method that has one call to the controller' do
    let(:obj) do
      h = {}
      h.store 'redirect_to', fake_controller.method(:redirect_to)
      h.store 'root_path', fake_controller.method(:root_path)
      described_class.new h
    end

    before :each do
      obj.call :anything_goes_here_even_nil
    end

    it '#root_path helper' do
      expect(fake_controller).to have(1).root_path_call
    end

    it '#redirect helper' do
      expect(fake_controller).to have(1).redirect
    end

    describe '#redirect helper with' do
      let(:redirect) { fake_controller.redirects.first }

      it 'the target path as the root path' do
        expect(redirect[0]).to eq fake_controller.root_path_literal
      end

      it 'options specifying the correct flash message' do
        expect(redirect[1]).to have_key :flash
        expect(redirect[1].count).to eq 1
        flash = redirect[1][:flash]
        expected = { alert: 'Not logged in as a registered user!' }
        expect(flash).to eq expected
      end
    end # describe '#redirect helper with'
  end # describe 'has a #call method that has one call to the controller'
end # describe PostsController::Responder::CreateFailure::UnregisteredUser
