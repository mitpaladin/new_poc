
require_relative 'implementation_draft_post_fields'
require_relative 'implementation_new_post_fields'
require_relative 'implementation_public_post_fields'
require_relative 'implementation_saved_post_fields'

shared_examples 'a converted implementation object' do |persistence, visibility|
  persist_str = persistence == :new_post ? 'new' : 'saved'
  visible_str = visibility == :draft_post ? 'draft' : 'public'

  context "for a #{persist_str} #{visible_str} post" do
    let(:entity_attribs) do
      FactoryGirl.attributes_for :post_datum,
                                 persistence,
                                 visibility,
                                 author_name: author_impl.name
    end

    it 'does not raise an error when called with a Post entity parameter' do
      expect { klass.from_entity post }.not_to raise_error
    end

    describe 'when called with a (valid) Post entity, it returns a' do

      it 'valid PostData instance' do
        expect(impl).to be_a PostData
        expect(impl).to be_valid
      end

      describe 'PostData instance with correct values for' do

        it 'basic content fields' do
          expect(impl.title).to eq post.title
          expect(impl.body).to eq post.body
          expect(impl.image_url).to eq post.image_url
          expect(impl.created_at).to eq post.created_at
        end

        it_behaves_like "implementation '#{persist_str} post' fields"

        it_behaves_like "implementation '#{visible_str} post' fields"
      end # describe 'PostData instance with correct values for'
    end # describe 'when called with a (valid) Post entity, it returns a'

  end # context "for a #{persist_str} #{visible_str} post"
end
