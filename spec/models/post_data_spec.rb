# == Schema Information
#
# Table name: post_data
#
#  id         :integer          not null, primary key
#  title      :string(255)      not null
#  body       :text
#  created_at :datetime
#  updated_at :datetime
#  image_url  :string(255)
#  pubdate    :datetime
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

      it 'an instance with a title but no body' do
        expect(FactoryGirl.build :post_datum, body: nil).to be_valid
      end

      it 'both title and body' do
        expect(FactoryGirl.build :post_datum, image_url: nil).to be_valid
      end

      it 'both title and image_url but no body' do
        expect(FactoryGirl.build :post_datum, body: nil).to be_valid
      end
    end # context 'is valid with'

    context 'is invalid with' do

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
    let(:post) { FactoryGirl.build :post_datum }

    it 'returns false when the "pubdate" field is nil' do
      expect(post).to_not be_published
    end

    it 'returns true when the "pubdate" field is set' do
      post.pubdate = 5.seconds.ago
      expect(post).to be_published
    end
  end # describe :published?
end
