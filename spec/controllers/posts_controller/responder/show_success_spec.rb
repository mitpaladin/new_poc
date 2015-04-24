
require 'spec_helper'

describe PostsController::Responder::ShowSuccess do
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
    let(:entity) do
      FactoryGirl.create :post, :image_post, :saved_post, :published_post
    end
    let(:ivar_pair) { fake_controller.ivars_set.first }
    let(:dao) { ivar_pair[1] }
    let(:obj) { described_class.new fake_controller }

    before :each do
      obj.respond_to entity
    end

    it 'retrieves a DAO instance assigned to the @post controller ivar' do
      expect(dao).to be_a PostRepository.new.dao
    end

    describe 'retrieves a DAO instance assigned to the @post controller ivar' do
      let(:time_attribs) { [:created_at, :updated_at, :pubdate] }
      let(:other_attribs) do
        attribs = entity.attributes.to_hash.symbolize_keys.keys
        attribs.reject { |k| time_attribs.include? k }
      end

      it 'that has attributes corresponding to those of the entity instance' do
        other_attribs.each do |attrib|
          expect(entity.send attrib).to eq dao.send(attrib)
        end
        time_attribs.each do |attrib|
          expect(entity.send attrib).to be_within(5.seconds).of dao.send(attrib)
        end
      end
    end # describe '... a DAO instance assigned to the @post controller ivar'
  end # describe 'has a #respond_to method that'
end # describe PostsController::Responder::ShowSuccess
