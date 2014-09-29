
require_relative 'entity_draft_post_fields'
require_relative 'entity_invalid_post_fields'
require_relative 'entity_new_post_fields'
require_relative 'entity_public_post_fields'
require_relative 'entity_saved_post_fields'
require_relative 'entity_unattached_post_fields'
require_relative 'entity_valid_post_fields'

shared_examples 'a converted entity' do |persistence, visibility, validity|
  persist_str = persistence == :new_post ? 'new' : 'saved'
  visible_str = visibility == :draft_post ? 'draft' : 'public'
  valid_str = validity == :valid ? 'valid' : 'invalid'

  context "for a #{valid_str} #{persist_str} #{visible_str} post" do
    let(:impl) do
      method = persistence == :new_post ? :build : :create
      FactoryGirl.send method,
                       :post_datum,
                       persistence,
                       visibility,
                       author_name: author.name,
                       created_at: ctime
    end
    let(:entity) { klass.to_entity impl }

    describe 'produces a Post' do

      it 'with basic content fields' do
        expect(entity.author_name).to eq author.name
        expect(entity.title).to eq impl.title
        expect(entity.body).to eq impl.body
        expect(entity.image_url).to eq impl.image_url
        expect(entity.created_at).to be_within(0.5.seconds).of ctime
      end

      it_behaves_like "entity '#{persist_str} post' fields"

      it_behaves_like "entity '#{visible_str} post' fields"

      it_behaves_like "entity 'unattached post' fields"

      it_behaves_like "entity '#{valid_str} post' fields"
    end # describe 'produces a Post'
  end # context "for a #{persist_str} #{visible_str} post"
end
