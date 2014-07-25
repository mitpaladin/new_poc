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
      let(:post) { FactoryGirl.build :post_datum }

      it 'matches the parameterised title' do
        expect(post.slug).to eq post.title.parameterize
      end
    end # context 'with a valid title'

    context 'with an invalid title' do
      let(:post) { FactoryGirl.build :post_datum, title: nil }

      it 'states that no title exists for this article' do
        expect(post.slug).to eq 'no-title-for-this-article'
      end
    end # context 'with an invalid title'

    # context 'where two articles have the same title' do
    #   let(:title) { 'This Is a Redundant, Duplicated Title' }
    #   let(:post1) { FactoryGirl.create :post_datum, title: title }
    #   let(:post2) { FactoryGirl.create :post_datum, title: title }
    #
    #   it 'should not generate the same slug' do
    #     expect(post1.slug).not_to eq post2.slug
    #   end
    # end # context 'where two articles have the same title'
  end # describe :slug
end
