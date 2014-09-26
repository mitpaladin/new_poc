
require 'spec_helper'

require 'cco/post_cco2'

require_relative 'post_shared_examples/post_shared_examples'

# Cross-layer conversion objects (CCOs).
module CCO
  describe PostCCO2 do
    let(:klass) { PostCCO2 }

    it 'has a .from_entity class method' do
      p = klass.public_method :from_entity
      expect(p.receiver).to be klass
    end

    it 'has a .to_entity class method' do
      p = klass.public_method :to_entity
      expect(p.receiver).to be klass
    end

    describe :to_entity.to_s do
      context 'specifying only the implementation object' do
        context 'for a valid new draft Post' do
          it_behaves_like 'an unattached entity', [:new_post, :draft_post]
          it_behaves_like 'a draft entity', [:new_post]
          it_behaves_like 'a valid entity', [:new_post, :draft_post]
          it_behaves_like 'an unsaved entity', [:draft_post]
          it_behaves_like 'an entity with standard attributes',
                          [:new_post, :draft_post],
                          [:author_name, :body, :image_url, :title]
        end # context 'for a valid new draft post'

        context 'for an invalid new draft post' do
          it_behaves_like 'a draft entity', [:new_post]
          it_behaves_like 'an invalid entity', :title, [:new_post, :draft_post]
          it_behaves_like 'an unsaved entity', [:draft_post]
          it_behaves_like 'an entity with standard attributes',
                          [:new_post, :draft_post],
                          [:author_name, :body, :image_url]
        end # context 'for an invalid new draft post'

        context 'for a valid saved draft post' do
          it_behaves_like 'an unattached entity', [:saved_post, :draft_post]
          it_behaves_like 'a draft entity', [:saved_post]
          it_behaves_like 'a valid entity', [:saved_post, :draft_post]
          it_behaves_like 'a saved entity', [:draft_post]
          it_behaves_like 'an entity with standard attributes',
                          [:draft_post, :saved_post],
                          [:author_name, :body, :image_url, :title]
        end # context 'for a valid saved draft post'

        context 'for an invalid saved draft post' do
          it_behaves_like 'an invalid entity', :title,
                          [:saved_post, :draft_post]
          it_behaves_like 'a saved entity', [:draft_post]
          it_behaves_like 'an entity with standard attributes',
                          [:draft_post, :saved_post],
                          [:author_name, :body, :image_url]
        end # context 'for an invalid saved draft post'

        context 'for a valid new public post' do
          it_behaves_like 'a public entity', [:new_post]
          it_behaves_like 'a valid entity', [:new_post, :public_post]
          it_behaves_like 'an unsaved entity', [:public_post]
          it_behaves_like 'an entity with standard attributes',
                          [:new_post, :public_post],
                          [:author_name, :body, :image_url, :title]
        end # context 'for a valid new public post'

        context 'for an invalid new public post' do
          it_behaves_like 'a public entity', [:new_post]
          it_behaves_like 'an invalid entity', :title, [:new_post, :public_post]
          it_behaves_like 'an unsaved entity', [:public_post]
          it_behaves_like 'an entity with standard attributes',
                          [:new_post, :public_post],
                          [:author_name, :body, :image_url]
        end # context 'for an invalid new public post'

        context 'for a valid saved public post' do
          it_behaves_like 'an unattached entity', [:saved_post, :public_post]
          it_behaves_like 'a public entity', [:saved_post]
          it_behaves_like 'a valid entity', [:saved_post, :public_post]
          it_behaves_like 'a saved entity', [:public_post]
          it_behaves_like 'an entity with standard attributes',
                          [:public_post, :saved_post],
                          [:author_name, :body, :image_url, :title]
        end # context 'for a valid saved public post'

        context 'for an invalid saved public post' do
          it_behaves_like 'an invalid entity', :title,
                          [:saved_post, :public_post]
          it_behaves_like 'a saved entity', [:public_post]
          it_behaves_like 'an entity with standard attributes',
                          [:public_post, :saved_post],
                          [:author_name, :body, :image_url]
        end # context 'for an invalid saved public post'
      end # context 'specifying only the implementation object'
    end # describe :from_entity
  end # describe CCO::PostCCO2
end # module CCO
