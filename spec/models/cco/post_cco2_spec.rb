
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

      context 'specifying both the implementation and parameter objects' do

        context 'specifying only a Blog instance' do
          let(:blog) { Blog.new }
          let(:impl) { FactoryGirl.build :post_datum, :saved_post, :draft_post }
          let(:entity) { CCO::PostCCO2.to_entity impl, blog: blog }

          it 'sets the "blog" instance variable on the entity' do
            expect(entity.blog).to be blog
          end

          it "adds the entity to the Blog's list of entries" do
            expect(blog.entry? entity).to be true
          end
        end # context 'specifying only a Blog instance'

        description = 'specifying a Blog instance and an add_to_blog value ' \
            'of false'
        context description do
          let(:blog) { Blog.new }
          let(:impl) { FactoryGirl.build :post_datum, :saved_post, :draft_post }
          let(:entity) do
            CCO::PostCCO2.to_entity impl, blog: blog, add_to_blog: false
          end

          it 'sets the "blog" instance variable on the entity' do
            expect(entity.blog).to be blog
          end

          it "does NOT add the entity to the Blog's list of entries" do
            expect(blog.entry? entity).to be false
          end
        end # context 'specifying a Blog instance and ... value of false'
      end # context 'specifying both the implementation and parameter objects'
    end # describe :to_entity

    describe :from_entity.to_s do

      context 'for a new draft post' do
        let(:author_impl) { FactoryGirl.create :user_datum }
        let(:blog) { Blog.new }
        let(:entity_attribs) do
          FactoryGirl.attributes_for :post_datum,
                                     :new_post,
                                     :draft_post,
                                     author_name: author_impl.name
        end
        let(:post) { blog.new_post entity_attribs }
        let(:impl) { klass.from_entity post }

        it 'does not raise an error when called with a Post entity parameter' do
          expect { klass.from_entity post }.not_to raise_error
        end

        describe 'when called with a (valid) Post entity, it returns a ' do

          it 'valid PostData instance' do
            expect(impl).to be_a PostData
            expect(impl).to be_valid
          end

          it 'new PostData instance' do
            expect(impl).to be_a_new_record
          end

          describe 'PostData instance with correct values for' do

            it 'basic content fields' do
              expect(impl.title).to eq post.title
              expect(impl.body).to eq post.body
              expect(impl.image_url).to eq post.image_url
              expect(impl.created_at).to eq post.created_at
            end

            it '"new post" fields' do
              expect(impl.updated_at).to be nil
              expect(impl.slug).to be_nil
              expect(impl.id).to be nil
            end

            it '"draft post" fields' do
              expect(impl.pubdate).to be nil
            end
          end # describe 'PostData instance with correct values for'
        end # describe 'when called with a (valid) Post entity, it returns a'
      end # context 'for a new draft post'

      context 'for a saved draft post'

      context 'for a new public post'

      context 'for a saved public post'

    end # describe :from_entity
  end # describe CCO::PostCCO2
end # module CCO
