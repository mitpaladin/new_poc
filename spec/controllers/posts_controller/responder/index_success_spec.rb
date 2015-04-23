
require 'spec_helper'

describe PostsController::Responder::IndexSuccess do
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
      obj.respond_to entities
    end

    describe 'assigns to the controller @posts instance variable' do
      let(:entities) do
        # Yes, this needs real, honest-to-`$DEITY` database records -- at least
        # until we get around to using a Repository DAO that stubs/mocks DB
        # access.
        daos = FactoryGirl.create_list :post, entity_count, :image_post,
                                       :saved_post, :published_post
        daos.map { |dao| PostFactory.create dao.attributes.symbolize_keys }
      end
      let(:entity_count) { 6 }
      let(:ivar_pair) { fake_controller.ivars_set.first }
      let(:daos) { ivar_pair[1] }

      it 'as expected' do
        expect(fake_controller).to have(1).ivars_set
        expect(ivar_pair.first).to be :@posts
      end

      describe 'as expected, including' do
        it 'being an enumeration of valid, persisted PostDao instances' do
          expect(daos).to respond_to :detect
          expect(daos).to have(entity_count).items
          daos.each do |dao|
            expect(dao).to be_a PostDao
            expect(dao).to be_valid
            expect(dao).to be_persisted
          end
        end

        description = 'the DAO fields reflect the non-persistence-timestamp' \
          ' attribute fields in each entity'
        it description do
          entities.each_with_index do |entity, entity_index|
            entity_fields = entity.attributes.to_hash.reject do |k, _v|
              [:created_at, :pubdate, :updated_at].include? k
            end
            dao = daos[entity_index]
            entity_fields.each_pair do |attrib, value|
              expect(dao[attrib]).to eq value
            end
            expect(dao[:pubdate]).to be_within(3.seconds).of entity.pubdate
          end # entities.each_with_index
        end

        it 'each post being extended with the presentation module' do
          [:build_body, :build_byline].each do |method_sym|
            daos.each { |dao| expect(dao).to respond_to method_sym }
          end
        end
      end # describe 'as expected, including'
    end # describe 'assigns to the controller @post instance variable'
  end # describe 'has a #respond_to method that'
end # describe PostsController::Responder::IndexSuccess
