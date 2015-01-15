
require 'spec_helper'

require_relative 'shared_examples/a_data_mapping_entity'

# Support class for #build_body specs.
class MarkupTestBuilder
  attr_reader :builder_name, :caller, :errors

  def initialize(caller_in, builder_name = 'ImageBodyBuilder')
    @caller = caller_in
    @builder_name = 'Newpoc::Entity::Post::SupportClasses::' + builder_name
    @errors = []
  end

  def build(source)
    @errors << 'Source and caller differ' unless caller_is?(source)
    bbc = source.send :body_builder_class
    unless bbc.name == builder_name
      @errors << format('Unexpected #body_builder_class "%s"', bbc.name)
    end
    'expected markup'
  end

  def caller_is?(source)
    caller.slug == source.slug && caller.class == source.class
  end
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
    let(:image_post_attribs) { published_attribs.merge image_url: image_url }
    let(:post) { described_class.new image_post_attribs }
    let(:text_post) { described_class.new published_attribs }

    it 'accepts one optional parameter' do
      method = post.public_method :build_body
      expect(method.arity).to eq(-1)
    end

    describe 'returns the correct markup for' do

      after :each do
        class_name = @class_name || 'ImageBodyBuilder'
        test_builder = MarkupTestBuilder.new @post, class_name
        markup = @post.build_body test_builder
        expect(markup).to eq 'expected markup'
        expect(test_builder.errors).to be_empty
      end

      it 'an image post' do
        @post = post
      end

      it 'a text post' do
        @post = text_post
        @class_name = 'TextBodyBuilder'
      end
    end # describe 'calls the appropriate builder for'
  end # describe '#build_body`
end # describe Newpoc::Entity::Post
