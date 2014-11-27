
require 'spec_helper'

require_relative 'shared_examples/a_data_mapping_entity'

# Specs for persistence entity-layer representation for User.
describe PostEntity do
  let(:klass) { PostEntity }
  let(:author_name) { 'Joe Palooka' }
  let(:image_url) { 'http://www.example.com/foo.png' }
  let(:title) { 'The Title' }
  let(:body) { 'The Body' }
  let(:valid_subset) do
    {
      title: title,
      slug: title.parameterize,
      author_name: author_name,
      body: body
    }
  end
  let(:invalid_attribs) do
    {
      bogus: 'This is invalid',
      forty_two: 41
    }
  end
  let(:all_attrib_keys) do
    %w(author_name body image_url slug title pubdate created_at updated_at)
      .map(&:to_sym).to_a
  end
  let(:draft_post) { klass.new valid_subset }
  let(:published_attribs) { valid_subset.merge pubdate: Time.now }
  let(:published_post) { klass.new published_attribs }

  it_behaves_like 'a data-mapping entity'

  describe :valid?.to_s do

    describe 'returns true when initialised with' do

      after :each do
        expect(klass.new @attribs).to be_valid
      end

      it 'an author name, title and body' do
        @attribs = { author_name: author_name, title: title, body: body }
      end

      it 'an author name, title and image URL' do
        @attribs = {
          author_name: author_name,
          title: title,
          image_url: image_url
        }
      end

      it 'an author name, title, image URL and body' do
        @attribs = {
          author_name: author_name,
          title: title,
          image_url: image_url,
          body: body
        }
      end
    end # describe 'returns true when initialised with'

    describe 'returns false when initialised with' do

      after :each do
        expect(klass.new @attribs).not_to be_valid
      end

      it 'no author name' do
        @attribs = { title: title, image_url: image_url, body: body }
      end

      it 'no title' do
        @attribs = {
          author_name: author_name,
          image_url: image_url,
          body: body
        }
      end

      it 'no body and no image URL' do
        @attribs = {
          author_name: author_name,
          title: title
        }
      end
    end # describe 'returns false when initialised with'
  end # describe :valid?

  describe :build_body do
    let(:post) { published_post }
    let(:text_post) do
      attribs = post.attributes
      attribs.delete :image_url
      klass.new attribs
    end

    it 'takes no parameters' do
      message = 'wrong number of arguments (1 for 0)'
      expect { post.build_body post }.to raise_error ArgumentError, message
    end

    # The method should NOT "render" *anything*. It should build either the
    # `figure` tag and contents, or the `p` tag and contents, as appropriate for
    # this instance of the model.
    describe 'generates the correct markup for' do

      # One issue with using RedCarpet as we are in our MarkdownHtmlConverter
      # class is that a simple string, e.g., 'foo', will always get converted to
      # aa paragraph with a trailing newline, e.g., "<p>foo</p>\n". This is,
      # AFAICT, acceptable within a <figcaption> tag per Mozilla's reference
      # (https://developer.mozilla.org/en-US/docs/Web/HTML/Element/figcaption).
      # It *is* "new behaviour" that broke this existing spec.
      it 'an image post' do
        post_attribs = post.attributes
        post_attribs[:image_url] = image_url
        post = klass.new post_attribs
        body_markup = "<p>#{post.body}</p>\n"
        expected = %(<figure><img src="#{post.image_url}">)
        expected += %(<figcaption>#{body_markup}</figcaption></figure>\n)
        expect(post.build_body).to eq expected
      end

      it 'a text post' do
        expect(text_post.build_body).to eq %(<p>#{post.body}</p>\n)
      end
    end # describe 'generates the correct markup for'
  end # describe :build_body

  describe :draft?.to_s do
    it 'returns false for a published post' do
      expect(published_post).not_to be_draft
    end

    it 'returns true for an unpublished post' do
      expect(draft_post).to be_draft
    end
  end # describe :draft?

  describe :published?.to_s do
    it 'returns true for a published post' do
      expect(published_post).to be_published
    end

    it 'returns false for an unpublished post' do
      expect(draft_post).not_to be_published
    end
  end

  describe :post_status.to_s do

    it 'returns "draft" for a draft post' do
      expect(draft_post.post_status).to eq 'draft'
    end

    it 'returns "public" for a published post' do
      expect(published_post.post_status).to eq 'public'
    end
  end # describe :post_status
end # describe PostEntity
