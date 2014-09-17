# == Schema Information
#
# Table name: post_data
#
#  id          :integer          not null, primary key
#  title       :string(255)      not null
#  body        :text
#  created_at  :datetime
#  updated_at  :datetime
#  image_url   :string(255)
#  pubdate     :datetime
#  author_name :string(255)
#  slug        :string(255)
#

require 'spec_helper'

describe PostData do
  let(:klass) { PostData }

  describe 'supports initialisation' do

    it 'with no parameters' do
      expect { klass.new }.to_not raise_error
    end

    it 'with a title parameter string only' do
      expect { FactoryGirl.create :post_datum, body: nil }.to_not raise_error
    end

    it 'with both title and body parameter strings' do
      expect { FactoryGirl.build :post_datum }.to_not raise_error
    end
  end # describe 'supports initialisation'

  describe 'reports validation correctly, showing that an instance' do

    context 'is valid with' do

      it 'an instance with an author name title but no body' do
        expect(FactoryGirl.build :post_datum, body: nil).to be_valid
      end

      it 'author name, title and body' do
        expect(FactoryGirl.build :post_datum, image_url: nil).to be_valid
      end

      it 'author_name, title and image_url but no body' do
        expect(FactoryGirl.build :post_datum, body: nil).to be_valid
      end
    end # context 'is valid with'

    context 'is invalid with' do

      it 'no author name' do
        expect(FactoryGirl.build :post_datum, author_name: nil).to_not be_valid
      end

      it 'no title' do
        expect(FactoryGirl.build :post_datum, title: nil).to_not be_valid
      end

      it 'neither a body nor an image URL' do
        expect(FactoryGirl.build :post_datum, body: nil, image_url: nil)
            .to_not be_valid
      end
    end # context 'is invalid with'
  end # describe 'reports validation correctly, showing that an instance'

  describe 'supports :post_status accessor methods for' do
    let(:obj) { klass.new }

    it 'reading' do
      obj.post_status = 'public'
      m = obj.public_method :post_status
      expect(m.arity).to eq 0
      expect(m.call).to eq 'public'
    end

    it 'writing' do
      expect(obj.post_status).to eq 'draft' # by default
      m = obj.public_method :post_status=
      expect(m.arity).to eq 1
      m.call 'public'
      expect(obj.post_status).to eq 'public'
    end
  end # describe 'supports :post_data accessor methods for'

  describe :published? do

    it 'has been removed; PostData no longer responds to :published?' do
      expect(FactoryGirl.build :post_datum).to_not respond_to :published?
    end
  end # describe :published?

  describe :slug do

    context 'with a valid title' do
      let(:post) { FactoryGirl.create :post_datum }

      it 'matches the parameterised title' do
        expect(post.slug).to eq post.title.parameterize
      end
    end # context 'with a valid title'

    # An invalid title violates a database-level constraint; no longer needed.

    context 'where two articles have the same title' do
      let(:title) { 'This Is a Redundant, Duplicated Title' }
      # eager evaluation so second-slug test passes
      let!(:post1) { FactoryGirl.create :post_datum, title: title }
      let!(:post2) { FactoryGirl.create :post_datum, title: title }

      describe 'they do not have the same slug value;' do
        it 'the first has a slug that is the parameterised title' do
          expect(post1.slug).to eq post1.title.parameterize
        end

        it 'the second has a slug that parameterises the title and author' do
          expected_parts = [post2.title, post2.author_name]
          expected_parts = expected_parts.map(&:parameterize)
          expect(post2.slug).to eq expected_parts.join('-')
        end
      end # describe 'they do not have the same slug value;'
    end # context 'where two articles have the same title'
  end # describe :slug

  describe :authored_by do
    let(:user) do
      ret = FactoryGirl.build :user_datum
      ret.send :set_slug  # private method normally used as AR callback
      ret
    end

    it 'with an unpublished user yields no posts' do
      expect(klass.authored_by user.name).to eq []
    end

    describe 'with a published user' do
      let!(:post1) { FactoryGirl.create :post_datum, author_name: user.name }
      let(:posts) { klass.authored_by user.name }

      it 'of a single post returns an array with that post in it' do
        expect(posts).to have(1).post
        expect(posts.first).to eq post1
      end

      it 'of multiple posts returns an array with each authored post in it' do
        new_post_count = 3
        new_posts = FactoryGirl.create_list :post_datum,
                                            new_post_count,
                                            author_name: user.name
        expect(posts).to have(new_post_count + 1).posts
        new_posts.each_with_index do |post, index|
          expect(posts[index + 1]).to eq post
        end
      end

      it 'who is one of multiple published authors returns only her posts' do
        new_post_count = 5
        new_post_count.times do
          new_author = FactoryGirl.create :user_datum
          FactoryGirl.create :post_datum, author_name: new_author.name
          FactoryGirl.create :post_datum, author_name: user.name
        end
        expect(posts).to have(new_post_count + 1).posts
        expect(PostData.all).to have((new_post_count * 2) + 1).posts
      end
    end # describe 'with a published user'
  end # describe :authored_by

end
