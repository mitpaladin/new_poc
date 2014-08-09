
require 'spec_helper'

describe 'User can view author profile from article page' do

  before :each do
    FeatureSpecLoginHelper.new(self).register_and_login
    FeatureSpecNewPostHelper.new(self).create_image_post
    click_link @post_title
  end

  describe 'by clicking on the author name in the' do

    after :each do
      within(:css, @css) { click_link @user_name }
      header = "Articles Authored By #{@user_name}"
      expect(page).to have_css 'h3', header
    end

    it 'list below the article content' do
      @css = 'div.row:first div.row:last dl'
    end

    it 'article byline' do
      @css = 'div.page-header h1'
    end

  end # describe 'by clicking on the author name in the'

end # describe 'User can view author profile from article page'
