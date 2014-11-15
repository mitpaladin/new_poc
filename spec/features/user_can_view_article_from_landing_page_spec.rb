
require 'spec_helper'

describe 'User can view article from landing page' do

  before :each do
    FeatureSpecLoginHelper.new(self).register_and_login
    FeatureSpecNewPostHelper.new(self).create_image_post
    # should be back on landing page now
  end

  it 'and see the article title link' do
    expect(page).to have_link @post_title, post_path(@post_slug)
  end

  it 'by clicking on the article title' do
    click_link @post_title
    expect(page).to have_css 'dl > dd', @user_name
  end
end # describe 'User can view article from landing page'
