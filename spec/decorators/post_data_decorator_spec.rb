
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

      it 'an image post' do
        post.image_url = 'http://www.example.com/foo.png'
        expected = %(<figure><img src="#{post.image_url}" />)
        expected += %(<figcaption>#{post.body}</figcaption></figure>\n)
        # expected = %(<figure><img src="#{post.image_url}" />) \
        #     %(<figcaption>#{post.body}</figcaption></figure>\n)
        expect(post.build_body).to eq expected
      end

      it 'a text post' do
        expect(text_post.build_body).to eq %(<p>#{post.body}</p>\n)
      end
    end # describe 'generates the correct markup for'
  end # describe :build_body

  describe :build_byline do
    let(:byline) { post.build_byline }

    it 'takes no parameters' do
      message = 'wrong number of arguments (1 for 0)'
      expect { post.build_byline 'foo' }.to raise_error ArgumentError, message
    end

    it 'returns a paragraph tag' do
      post.publish
      pubdate = post.pubdate.localtime.strftime '%c %Z'
      expected = '<p><time pubdate="pubdate">' \
          "Posted #{pubdate} by #{post.author_name}" \
          '</time></p>'
      expect(byline).to eq expected
    end
  end # describe :build_byline

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
