
require 'spec_helper'

describe PostsController::Responder::EditSuccess do
  describe 'initialisation' do
    context 'succeeds when passed a parameter that' do
      let(:param) do
        # Dummy class for testing initialisation. Methods don't have to *do*
        # anything yet; they just have to be there.
        Class.new do
          def instance_variable_set(_name_or_sym, _value)
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
        attr_reader :ivars_set

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

    context 'when passed a valid entity, it' do
      let(:entity) do
        # Yes, this needs a real, honest-to-`$DEITY` database record -- at least
        # until we get around to using a Repository DAO that stubs/mocks DB
        # access.
        dao = FactoryGirl.create :post, :image_post, :saved_post,
                                 :published_post
        PostFactory.create dao.attributes.symbolize_keys
      end
      let(:ivar_pair) { fake_controller.ivars_set.first }
      let(:dao) { ivar_pair[1] }

      it 'assigns a :@post instance variable on the controller' do
        expect(fake_controller).to have(1).ivars_set
        expect(ivar_pair.first).to be :@post
      end

      describe 'assigns the :@post ivar on the controller such that' do
        it 'is a valid, persisted PostDao' do
          expect(dao).to be_a PostDao
          expect(dao).to be_valid
          expect(dao).to be_persisted
        end

        description = 'the DAO fields reflect the non-persistence-timestamp' \
          ' attribute fields in the entity'
        it description do
          entity_fields = entity.attributes.to_hash.reject do |k, _v|
            [:created_at, :pubdate, :updated_at].include? k
          end
          entity_fields.each_pair do |attrib, value|
            expect(dao[attrib]).to eq value
          end
          expect(dao[:pubdate]).to be_within(3.seconds).of entity.pubdate
        end

        it 'the DAO instance is extended with the presentation module' do
          [:draft?, :published?].each do |method_sym|
            expect(dao).to respond_to method_sym
          end
        end
      end # describe 'assigns the :@post ivar on the controller such that'
    end # context 'when passed a valid entity, it'
  end # describe 'has a #respond_to method that'
end # describe PostsController::Responder::EditSuccess
