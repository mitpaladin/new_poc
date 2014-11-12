
require 'spec_helper'

require 'draper'

require 'post_data_decorator'

describe PostDataDecorator do
  let(:post_attribs) do
    attribs = FactoryGirl.attributes_for :post_datum
    attribs[:blog] = Blog.new
    attribs
  end
  let(:post) do
    PostDataDecorator.new(Post.new post_attribs)
  end
  let(:text_post) do
    attribs = post_attribs
    attribs.delete :image_url
    PostDataDecorator.new(Post.new attribs)
  end

  it 'decorates the model' do
    expect(post).to be_decorated
  end

  describe :build_body do

    it 'takes no parameters' do
      message = 'wrong number of arguments (1 for 0)'
      expect { post.build_body post }.to raise_error ArgumentError, message
    end

    it 'delegates method calls to the post' do
      post.title = 'TITLE'
      expect(post.title).to eq 'TITLE'
      post.body = 'BODY'
      expect(post.body).to eq 'BODY'
      post.image_url = 'IMAGE URL'
      expect(post.image_url).to eq 'IMAGE URL'
      # FIXME: We skipped section 10, idiot!
      post.pubdate = 'PUBDATE'
      expect(post.pubdate).to eq 'PUBDATE'
    end

    # The method should NOT "render" *anything*. It should build either the
    # `figure` tag and contents, or the `p` tag and contents, as appropriate for
    # this instance of the model. NO PARTIALS ARE NEEDED. D'oh!
    describe 'generates the correct markup for' do

      # One issue with using RedCarpet as we are in our MarkdownHtmlConverter
      # class is that a simple string, e.g., 'foo', will always get converted to
      # aa paragraph with a trailing newline, e.g., "<p>foo</p>\n". This is,
      # AFAICT, acceptable within a <figcaption> tag per Mozilla's reference
      # (https://developer.mozilla.org/en-US/docs/Web/HTML/Element/figcaption).
      # It *is* "new behaviour" that broke this existing spec.
      it 'an image post' do
        post.image_url = 'http://www.example.com/foo.png'
        body_markup = "<p>#{post.body}</p>\n"
        expected = %(<figure><img src="#{post.image_url}" />)
        expected += %(<figcaption>#{body_markup}</figcaption></figure>\n)
        expect(post.build_body).to eq expected
      end

      it 'a text post' do
        expect(text_post.build_body).to eq %(<p>#{post.body}</p>\n)
      end
    end # describe 'generates the correct markup for'
  end # describe :build_body

  xdescribe :build_byline do
    let(:byline) { post.build_byline }

    it 'takes no parameters' do
      message = 'wrong number of arguments (1 for 0)'
      expect { post.build_byline 'foo' }.to raise_error ArgumentError, message
    end

    it 'returns a paragraph tag' do
      post.publish
      expected = '<p><time pubdate="pubdate">' \
          "Posted #{post.pubdate_str} by #{post.author_name}" \
          '</time></p>'
      expect(byline).to eq expected
    end
  end # describe :build_byline

  describe :pubdate_str do
    context 'for a published post' do
      before :each do
        post.publish
      end

      it 'returns the correctly-formatted string equivalent of #pubdate' do
        expect(post.pubdate_str).to eq post.timestamp_for(post.pubdate)
      end
    end # context 'for a published post'

    context 'for a draft post' do
      it 'returns the string "DRAFT"' do
        expect(post.pubdate_str).to eq 'DRAFT'
      end
    end # context 'for a draft post'
  end # describe :pubdate_str

  describe :published? do
    let(:post) { FactoryGirl.build(:post_datum).decorate }

    it 'returns false when the "pubdate" field is nil' do
      expect(post).to_not be_published
    end

    it 'returns true when the "pubdate" field is set' do
      post.pubdate = 5.seconds.ago
      expect(post).to be_published
    end
  end # describe :published?

end # describe PostDataDecorator
