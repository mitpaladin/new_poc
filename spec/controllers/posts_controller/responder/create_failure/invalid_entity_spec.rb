
require 'spec_helper'

describe PostsController::Responder::CreateFailure::InvalidEntity do
  let(:fake_controller) do
    Class.new do
      attr_reader :ivars_set, :renders, :root_path_calls

      def initialize
        @ivars_set = []
        @renders = []
        @root_path_calls = []
      end

      def instance_variable_set(*args)
        @ivars_set.push args
      end

      def render(*args)
        @renders.push args
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
    describe 'fails when' do
      it 'no parameters are specified' do
        expect { described_class.new }.to raise_error KeyError
      end
    end # describe 'fails when'

    describe 'succeeds when called with' do
      it 'a controller-like parameter' do
        h = { 'post_setter' => :post_setter, 'render' => :render }
        expect { described_class.new h }.not_to raise_error
      end
    end # describe 'succeeds when called with'
  end # describe 'has initialisation that'

  describe 'has a class method .applies? that' do
    describe 'fails when passed a parameter that' do
      it 'does not respond to the :message message' do
        param = 'bogus'
        attempt = -> (p) { described_class.applies? p }
        expect { attempt.call param }.to raise_error ParamContractError,
                                                     /Actual: "bogus"/
      end
    end # describe 'fails when passed a parameter that'

    describe 'returns false when passed a parameter that' do
      it 'contains a message containing other than a JSON Hash' do
        payload = RuntimeError.new 'This is NOT a Hash.'
        expect(described_class.applies? payload).to be false
      end

      it 'does not contain any supported keys in the :message hash' do
        attribs = { foo: 'bar', meaning: nil, life: 42 }
        payload = RuntimeError.new JSON.dump attribs
        expect(described_class.applies? payload).to be false
      end
    end # describe 'returns false when passed a parameter that'

    describe 'returns true when passed a parameter message Hash containing' do
      describe 'at least one valid post core attribute, including' do
        [:title, :slug, :author_name, :body, :image_url].each do |attrib|
          it ":#{attrib}" do
            attribs = {}.tap { |h| h.store attrib, 'some-value' }
            payload = RuntimeError.new JSON.dump attribs
            expect(described_class.applies? payload).to be true
          end
        end
      end # describe 'at least one valid post core attribute, including'
    end # describe '...true when passed a parameter message Hash containing'
  end # describe 'has a class method .applies that'

  describe 'has an instance method #call that' do
    let(:obj) do
      post_setter = lambda do |dao|
        fake_controller.instance_variable_set :@post, dao
      end
      render = fake_controller.method :render
      h = { 'post_setter' => post_setter, 'render' => render }
      described_class.new h
    end

    it 'requires one parameter' do
      expect { obj.call }.to raise_error ArgumentError,
                                         /wrong number of arguments/
    end

    context 'when passed in a valid payload' do
      let(:payload) do
        # Attributes to a post that is invalid because it has no title
        RuntimeError.new JSON.dump(author_name: 'Author', body: 'Body')
      end
      let!(:result) { obj.call payload }

      it 'does not raise an error' do
        expect { result }.not_to raise_error
      end

      describe 'calls the post_setter' do
        it 'once' do
          expect(fake_controller).to have(1).ivars_set
        end

        it 'with an invalid PostDao instance' do
          ivar_set = fake_controller.ivars_set.first
          expect(ivar_set[0]).to be :@post
          expect(ivar_set[1]).to be_a PostDao
          expect(ivar_set[1]).to be_invalid
        end
      end # describe 'calls the post_setter'

      describe 'calls the renderer' do
        it 'once' do
          expect(fake_controller.renders.count).to eq 1
        end

        it 'with the template name, "new"' do
          expect(fake_controller.renders.first).to eq ['new']
        end
      end # describe 'calls the renderer'
    end # context 'when passed in a valid payload'
  end # describe 'has an instance method #call that'
end
