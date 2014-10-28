
require 'spec_helper'

require 'support/feature_spec/login_helper'
require 'support/feature_spec/new_post_helper'

def expected(title)
  %("#{title}" Published DRAFT)
end

def list_item_css
  '#contrib-row > ul > li'
end

def link_css(title)
  "a[href='/posts/#{title.parameterize}']"
end

xdescribe 'Member can create a draft post and see' do

  before :each do
    FeatureSpecLoginHelper.new(self).register_and_login
    data = PostHelperSupport::PostCreatorData.new post_status: 'draft'
    FeatureSpecNewPostHelper.new(self, data).create_image_post
  end

  it 'the confirmation flash message' do
    expect(page).to have_text 'Post added!'
  end

  it 'the newly-entered article details on his profile page' do
    visit user_path(@user_name.parameterize)
    list_item = page.find list_item_css
    link = list_item.find link_css(@post_title)
    expect(link).to have_text expected(@post_title)
  end

end # describe 'Member can create a draft post and see'
