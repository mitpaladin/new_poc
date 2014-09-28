
require 'spec_helper'

require 'cco/post_cco2'

require_relative 'post_shared_examples/post_shared_examples'

shared_examples "entity 'draft post' fields" do
  it '"draft post" fields' do
    expect(entity.pubdate).to be nil
  end
end

shared_examples "entity 'new post' fields" do
  it '"new post" fields' do
    expect(entity.slug).to be nil
  end
end

shared_examples 'a converted entity' do |persistence, visibility|
  persist_str = persistence == :new_post ? 'new' : 'saved'
  visible_str = visibility == :draft_post ? 'draft' : 'public'

  context "for a #{persist_str} #{visible_str} post" do
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

      # it_behaves_like "entity 'unattached post' fields"

      # it_behaves_like "entity 'valid post' fields"
    end # describe 'produces a Post'
  end # context "for a #{persist_str} #{visible_str} post"
end

# Cross-layer conversion objects (CCOs).
module CCO
  describe PostCCO2 do
    let(:author) { FactoryGirl.build :user_datum }
    let(:ctime) { DateTime.now.to_time }
    let(:klass) { PostCCO2 }

    describe :to_entity.to_s do
      context 'specifying only the implementation object' do

        it_behaves_like 'a converted entity', :new_post, :draft_post

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
      let(:author_impl) { FactoryGirl.create :user_datum }
      let(:blog) { Blog.new }
      let(:post) { blog.new_post entity_attribs }
      let(:impl) { klass.from_entity post }

      [:new_post, :saved_post].each do |persist|
        [:draft_post, :public_post].each do |visible|
          it_behaves_like 'a converted implementation object', persist, visible
        end
      end
    end # describe :from_entity
  end # describe CCO::PostCCO2
end # module CCO
