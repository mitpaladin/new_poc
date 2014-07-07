
require 'spec_helper'

require 'draper'

require 'post_data_decorator'

describe PostDataDecorator do

  # We can't do `Post.new(...).decorate` unless Post is a genuine ActiveModel.
  # ActiveAttr *does not* quack quite right.
  # See https://github.com/drapergem/draper/issues/619
  subject(:post) { PostDataDecorator.decorate(Post.new blog: Blog.new) }

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
      # post.pubdate = 'PUBDATE'
      # expect(post.pubdate).to eq 'PUBDATE'
    end

    # The method should NOT "render" *anything*. It should build either the
    # `figure` tag and contents, or the `p` tag and contents, as appropriate for
    # this instance of the model. NO PARTIALS ARE NEEDED. D'oh!
    describe 'generates the correct markup for' do

      before :each do
        post.title = 'A Title'
        post.body = 'A Body or Caption'
      end

      it 'an image post' do
        post.image_url = 'http://www.example.com/foo.png'
        format_str = '<figure>' \
          '<img src="%s" />' \
          '<figcaption>%s</figcaption>' \
          '</figure>'
        expected = format format_str, post.image_url, post.body
        expect(post.build_body).to eq expected
      end

      it 'a text post' do
        expected = ['<p>', '</p>'].join post.body
        expect(post.build_body).to eq expected
      end
    end # describe 'generates the correct markup for'
  end # describe :build_body

end # describe PostDataDecorator
