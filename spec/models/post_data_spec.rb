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
end
