
require 'spec_helper'

describe PostsController::Responder::UpdateSuccess do
  describe 'initialisation' do
    context 'succeeds when passed a parameter that' do
      let(:param) do
        # Dummy class for testing initialisation. Methods don't have to *do*
        # anything yet; they just have to be there.
        Class.new do
          def instance_variable_set
          end

          def redirect_to
          end

          def post_path
          end
        end.new
      end

      it 'implements the three required controller methods' do
        expect { described_class.new param }.not_to raise_error
      end
    end # context 'succeeds when passed a parameter that'
  end # describe 'initialisation'

  describe 'has a #respond_to method that' do
    let(:time_window) { 0.5.seconds }
    let(:fake_controller) do
      Class.new do
        attr_reader :ivars_set, :redirects, :post_path_calls

        def initialize
          @ivars_set = []
          @redirects = []
          @post_path_calls = []
        end

        def instance_variable_set(ivar_sym, value)
          @ivars_set.push [ivar_sym, value]
          value
        end

        def redirect_to(*args)
          @redirects.push args
          # don't care about faking a return value here
        end

        def post_path(*args)
          @post_path_calls.push args
          post_path_literal
        end

        def post_path_literal
          '/'
        end
      end.new
    end
    let(:obj) { described_class.new fake_controller }

    before :each do
      obj.respond_to entity
    end

    context 'when passed a valid entity, it' do
      let(:entity) do
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
        it 'is a valid PostDao' do
          expect(dao).to be_a PostDao
          expect(dao).to be_valid
        end

        description = 'the DAO fields reflect the non-timestamp' \
          ' attribute fields in the entity'
        it description do
          entity_fields = entity.attributes.to_hash.reject do |k, _v|
            [:created_at, :updated_at, :pubdate].include? k
          end
          entity_fields.each_pair do |attrib, value|
            expect(dao[attrib]).to eq value
          end
        end

        it 'the non-updated DAO field timestamps match those in the entity' do
          [:pubdate, :created_at, :updated_at].each do |t|
            expect(dao.send t).to be_within(time_window).of entity.send t
          end
        end
      end # describe 'assigns the :@post ivar on the controller such that'

      it 'calls the #post_path method on the controller once' do
        expect(fake_controller).to have(1).post_path_call
      end

      describe 'calls the #redirect_to method on the controller' do
        it 'once' do
          expect(fake_controller).to have(1).redirect
          path, options = fake_controller.redirects.first
          expect(path).to eq fake_controller.post_path_literal
          success = "Post '#{dao.title}' successfully updated."
          expect(options).to eq(flash: { success: success })
        end
      end # describe 'calls the #redirect_to method on the controller'
    end # context 'when passed a valid entity, it'
  end # describe 'has a #respond_to method that'
end # describe PostsController::Responder::UpdateSuccess
