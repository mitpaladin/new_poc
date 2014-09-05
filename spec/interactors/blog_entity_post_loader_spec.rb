
require 'spec_helper'

require 'blog_entity_post_loader'

# Module DSO contains our Domain Service Objects, aka "interactors".
module DSO
  describe BlogEntityPostLoader do
    let(:klass) { BlogEntityPostLoader }
    let(:blog) { Blog.new }

    context 'for a blog with posts' do
      let(:post_count) { 10 }
      before :each do
        FactoryGirl.create_list :post_datum, post_count
        @posts = klass.run! blog: blog
      end

      it 'returns the actual Array of posts added to the blog as the result' do
        # note the object identity, not mere equality
        expect(@posts).to be blog.entries
      end

      it 'adds the correct number of entries to the blog' do
        expect(blog).to have(post_count).entries
      end
    end # context 'for a blog with posts'

    context 'for a blog with no posts' do
      it "sets the blog's #entries to an empty array" do
        klass.run! blog: blog
        expect(blog.entries).to be_empty
      end
    end
  end # describe DSO::BlogEntityPostLoader
end # module DSO
