
require 'spec_helper'

describe PostsController::Responder::NewSuccess do
  describe 'initialisation' do
    context 'succeeds when passed a parameter that' do
      let(:param) do
        # Dummy class for testing initialisation. Methods don't have to *do*
        # anything yet; they just have to be there.
        Class.new do
          def instance_variable_set
          end
        end.new
      end

      it 'implements the required controller method' do
        expect { described_class.new param }.not_to raise_error
      end
    end # context 'succeeds when passed a parameter that'
  end # describe 'initialisation'

  describe 'has a #respond_to method that' do
    let(:fake_controller) do
      Class.new do
        attr_reader :ivars_set, :redirects, :root_path_calls

        def initialize
          @ivars_set = []
        end

        def instance_variable_set(ivar_sym, value)
          @ivars_set.push [ivar_sym, value]
          value
        end
      end.new
    end
    let(:obj) { described_class.new fake_controller }

    before :each do
      obj.respond_to entity
    end

    describe 'creates a DAO instance assigned to the @post controller ivar' do
      let(:author_name) { 'Some Author' }
      let(:entity) { PostFactory.create author_name: author_name }
      let(:ivar_pair) { fake_controller.ivars_set.first }
      let(:dao) { ivar_pair[1] }

      it 'that has no attributes set other than the author name' do
        expect(dao.author_name).to eq author_name
        attribs = dao.attributes.reject { |k, _v| k == 'author_name' }
        expect(attribs.values.reject(&:nil?)).to be_empty
      end
    end # describe '... a DAO instance assigned to the @post controller ivar'
  end # describe 'has a #respond_to method that'
end # describe PostsController::Responder::NewSuccess
