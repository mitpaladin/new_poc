
require 'spec_helper'

describe PostsController::Responder::CreateFailure::InvalidEntity do
  describe 'has initialisation that' do
    describe 'fails when' do
      it 'no parameters are specified' do
        expect { described_class.new }.to raise_error KeyError
      end

      describe 'a Hash is supplied that has no value for key' do
        it '"post_setter"' do
          params = { 'reunder' => -> { :render_returned } }
          expect { described_class.new params }.to raise_error KeyError,
                                                               /"post_setter"/
        end

        it '"render"' do
          params = { 'post_setter' => -> { :post_setter_returned } }
          expect { described_class.new params }.to raise_error KeyError,
                                                               /"render"/
        end
      end # describe 'a Hash is supplied that has no value for key'
    end # describe 'fails when'
  end # describe 'has initialisation that'

  describe 'has a class method .applies? that' do
    describe 'fails when passed a parameter that' do
      it 'does not respond to the :message message' do
        param = 'bogus'
        expect { described_class.applies? param }.to raise_error NoMethodError,
                                                                 /`message'/
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
    let(:init_ivars) do
      {
        'post_setter' => mock_post_setter,
        'render' => mock_render
      }
    end
    let(:mock_post_setter) { -> (post) { posts.push post } }
    let(:mock_render) { -> (*args) { render_args.push args } }
    let(:posts) { [] }
    let(:render_args) { [] }
    let(:obj) { described_class.new init_ivars }

    it 'requires one parameter' do
      message = 'wrong number of arguments (0 for 1)'
      expect { obj.call }.to raise_error ArgumentError, message
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
          expect(posts).to have(1).item
        end

        it 'with an invalid PostDao instance' do
          expect(posts.first).to be_a PostDao
          expect(posts.first).to be_invalid
        end
      end # describe 'calls the post_setter'

      it 'calls the :post_setter once, with an invalid PostDao' do
        expect(posts).to have(1).item
        expect(posts.first).to be_a PostDao
        expect(posts.first).not_to be_valid
      end

      describe 'calls the renderer' do
        it 'once' do
          expect(render_args).to have(1).item
        end

        it 'with the template name, "new"' do
          expect(render_args.first).to eq ['new']
        end
      end # describe 'calls the renderer'
    end # context 'when passed in a valid payload'
  end # describe 'has an instance method #call that'
end
