
require 'spec_helper'

require 'blog_selector'

require 'support/shared_examples/models/error_message_list_state'
require 'support/shared_examples/models/post_field_comparison'
require 'support/shared_examples/models/post_field_priority'

describe Post do
  let(:blog) { DSO::BlogSelector.run! }
  let(:post_attribs) { FactoryGirl.attributes_for :post_datum }
  let(:post) { Post.new post_attribs }

  context 'initialisation' do

    it 'starts with blank (nil) attributes by default' do
      post = Post.new
      expect(post.title).to be_nil
      expect(post.body).to be_nil
      expect(post.blog).to be_nil
      expect(post.image_url).to be_nil
      expect(post.pubdate).to be_nil
    end

    it 'supports setting attributes in the initialiser' do
      post = Post.new title: 'A Title', body: 'A Body'
      expect(post.title).to eq 'A Title'
      expect(post.body).to eq 'A Body'
    end

    it 'does not support setting arbitrary attributes in the initialiser' do
      post = Post.new title: 'Title', body: 'Body', foo: 'Bar'
      expect(post.instance_variables).to_not include :@foo
    end
  end # context 'initialisation'

  describe 'supports reading and writing' do

    it 'a title' do
      post.title = 'Title'
      expect(post.title).to eq 'Title'
    end

    it 'a post body' do
      post.body = 'The Body'
      expect(post.body).to eq 'The Body'
    end

    it 'the publication date' do
      post.pubdate = Chronic.parse '1 July 2014 at 4.15 PM'
      expect(post.pubdate.to_s).to match(/2014-07-01 16:15:00 [\+\-]\d{4}/)
    end

    it 'supports reading and writing a blog reference' do
      blog = Object.new
      post.blog = blog
      expect(post.blog).to be blog
    end
  end # describe 'supports reading and writing'

  describe 'supports reading the attribute' do
    [:author_name, :slug].each do |attr_sym|
      it ":#{attr_sym}" do
        post = Post.new post_attribs
        expect(post.send attr_sym).to eq post_attribs[attr_sym]
      end
    end
  end # describe 'supports reading the attribute'

  describe 'DOES NOT support modifying the attribute' do
    [:author_name, :slug].each do |attr_sym|
      it ":#{attr_sym}" do
        setter = [attr_sym.to_s, '='].join.to_sym
        error_match = Regexp.new("undefined method `#{setter}' for .*?")
        post = Post.new post_attribs
        expect { post.send setter, 'anything at all' }
            .to raise_error NoMethodError, error_match
      end
    end
  end # describe 'DOES NOT support modifying the attribute'

  it 'does not change the slug value when the title changes' do
    post = Post.new post_attribs
    post.title = 'And Now For Something Completely Different'
    expect(post.slug).to eq post_attribs[:slug]
  end

  describe :error_messages do

    context 'when called on a valid post' do
      let(:post) { blog.new_post post_attribs }

      it_behaves_like 'error-message list empty-state check'
    end # context 'when called on a valid post'

    context 'when called on an invalid post' do
      let(:post) do
        blog.new_post post_attribs.merge(title: nil)
      end

      it_behaves_like 'error-message list empty-state check', false

      it 'returns the correct error message in the array' do
        expect(post).to have(1).error_message
        expect(post.error_messages.first).to match(/\ATitle .+?\z/)
        # expect(post.error_messages).to include "Title can't be blank"
      end
    end # context 'when called on an invalid post'
  end # describe :error_messages

  describe :publish do
    let(:post) { blog.new_post post_attribs }

    it 'adds the post to the blog' do
      expect(blog.entry? post).to be false
      post.publish
      expect(blog.entry? post).to be true
    end

    describe 'sets the "pubdate" attribute on a newly-published post' do

      it 'to the current time by default' do
        expect(post.pubdate).to be nil
        stamp = Time.now
        post.publish
        expect(post.pubdate.to_s).to eq stamp.to_s
      end

      it 'to a time specified as a parameter to #publish' do
        stamp = Chronic.parse '1 July 2014 at 4.15 PM'
        post.publish stamp
        expect(post.pubdate.to_s).to eq stamp.to_s
      end
    end # describe 'sets the "pubdate" attribute on a newly-published post'
  end # describe :publish

  describe :published? do

    it 'returns false for a newly-created Post' do
      expect(Blog.new.new_post).to_not be_published
    end

    it 'returns true after a post has been publsihed' do
      post = blog.new_post title: 'A Title', body: 'A Body'
      post.publish
      expect(post).to be_published
    end
  end

  describe :valid? do
    let(:post) { Post.new post_attribs }

    describe 'returns true for a post with' do

      after :each do
        expect(post).to be_valid
      end

      it 'a body and an image URL both present' do
      end

      it 'an empty body and an image URL that is not empty' do
        post.body = ''
      end

      it 'an empty image URL and a body that is not empty' do
        post.image_url = ''
      end
    end # describe 'returns true for a post with'

    describe 'returns false for a post with' do

      after :each do
        expect(post).to_not be_valid
      end

      it 'an empty title' do
        post.title = ''
      end

      it 'both an empty body and an empty image URL' do
        post.body = ''
        post.image_url = ''
      end
    end # describe 'returns false for a post with'
  end # describe :valid?

  describe '<=>' do
    it 'reports two posts as "equal" when they have the same field values' do
      post = Post.new post_attribs
      post2 = post.clone
      expect(post2).to eq post
    end

    it_behaves_like 'Post field comparison', :title

    it_behaves_like 'Post field comparison', :body

    it_behaves_like 'Post field comparison', :image_url

    it_behaves_like 'Post field comparison',
                    :pubdate,
                    higher: Chronic.parse('yesterday at 5 PM'),
                    lower:  Chronic.parse('yesterday at 9 AM')

    description = 'reports a post as greater than another if its publication' \
        ' date is set when the other is not'
    it description do
      post = Post.new post_attribs
      post2 = post.clone
      post2.pubdate = Chronic.parse('yesterday at 9 AM')
      expect(post2 > post).to be true
    end

    it_behaves_like 'Post field priority',
                    priority: :pubdate,
                    others:   [:title, :body, :image_url],
                    higher:   Chronic.parse('yesterday at 5 PM'),
                    lower:    Chronic.parse('yesterday at 9 AM')

    it_behaves_like 'Post field priority',
                    priority: :title,
                    others:   [:body, :image_url]

    it_behaves_like 'Post field priority',
                    priority: :body,
                    others:   [:image_url]

  end # describe '<=>'

  describe :to_h do
    it 'returns a Hash' do
      expect(post.to_h).to be_a Hash
    end

    describe 'contains all expected keys, including' do
      [:title, :body, :image_url, :author_name, :slug].each do |attr|
        it ":#{attr}" do
          expect(post.to_h[attr]).to eq post_attribs[attr]
        end
      end

      it :pubdate do
        expect(post.to_h).to have_key :pubdate
      end
    end # describe 'contains all expected keys, including'
  end

end # describe Post
