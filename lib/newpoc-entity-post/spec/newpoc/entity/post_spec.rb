
require 'spec_helper'

require_relative 'shared_examples/a_data_mapping_entity'

def expected_figure_markup(image_url, post_body)
  caption = "<figcaption><p>#{post_body}</p></figcaption>"
  tag = %(<img src="#{image_url}" style="max-width:100%;">)
  image = %(<a href="#{image_url}" target="_blank">) + tag + '</a>'
  '<figure>' + image + caption + '</figure>'
end

describe Newpoc::Entity::Post do
  let(:author_name) { 'Joe Palooka' }
  let(:image_url) { 'http://www.example.com/foo.png' }
  let(:title) { 'The Title' }
  let(:title_param) { 'the-title' }
  let(:body) { 'The Body' }

  let(:invalid_attribs) do
    {
      bogus: 'This is invalid',
      forty_two: 41
    }
  end
  let(:published_attribs) { valid_subset.merge pubdate: Time.now }
  let(:published_post) { described_class.new published_attribs }
  let(:valid_subset) do
    {
      title: title,
      slug: title_param,
      author_name: author_name,
      body: body
    }
  end

  it 'has a version number' do
    expect(Newpoc::Entity::Post::VERSION).not_to be nil
  end

  it_behaves_like 'a data-mapping entity'

  describe 'supports initialisation' do
    describe 'succeeding' do
      it 'with any combination of valid field names' do
        expect { described_class.new valid_subset }.not_to raise_error
      end

      it 'with invalid field names' do
        expect { described_class.new invalid_attribs }.not_to raise_error
      end
    end # describe 'succeeding'
  end # describe 'supports initialisation'

  describe '#valid?' do

    describe 'returns true when initialised with' do

      after :each do
        expect(described_class.new @attribs).to be_valid
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
        expect(described_class.new @attribs).not_to be_valid
      end

      it 'no author name' do
        @attribs = { title: title, image_url: image_url, body: body }
      end

      # Entity validation doesn't hit the database, so it can't tell if a name
      # is actually invalid; all it can do is determine that it's not what it
      # thinks the guest user name is.
      # it 'an invalid author name' do
      #   @attribs = {
      #     author_name: 'Invalid Author Name',
      #     title: title,
      #     image_url: image_url,
      #     body: body
      #   }
      # end

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
  end # describe '#valid?''

  describe '#build_body' do
    let(:post) { published_post }
    let(:text_post) do
      attribs = post.attributes
      attribs.delete :image_url
      described_class.new attribs
    end

    it 'takes no parameters' do
      message = 'wrong number of arguments (1 for 0)'
      expect { post.build_body post }.to raise_error ArgumentError, message
    end

    describe 'generates the correct markup for' do
      it 'an image post' do
        post_attribs = post.attributes
        post_attribs[:image_url] = image_url
        post = described_class.new post_attribs
        expected = expected_figure_markup(image_url, post.body)
        expect(post.build_body).to eq expected
      end

      it 'a text post' do
        expect(text_post.build_body).to eq %(<p>#{post.body}</p>)
      end
    end # describe 'generates the correct markup for'
  end # describe '#build_body`

end
