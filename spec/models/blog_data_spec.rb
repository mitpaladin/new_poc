# == Schema Information
#
# Table name: blog_data
#
#  id         :integer          not null, primary key
#  title      :string(255)      not null
#  subtitle   :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe BlogData do
  before :each do
    BlogData.delete_all
    FactoryGirl.create :blog_datum
  end

  describe 'has in its first record' do
    subject(:blog) { BlogData.first }

    it 'has the correct title' do
      expect(blog.title).to eq 'Watching Paint Dry'
    end

    it 'has the correct subtitle' do
      subtitle = 'The trusted source for drying paint news & opinion'
      expect(blog.subtitle).to eq subtitle
    end
  end # describe 'has in its first record'
end # describe BlogData
