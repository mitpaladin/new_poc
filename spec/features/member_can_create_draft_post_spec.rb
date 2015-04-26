
require 'spec_helper'

require 'support/feature_spec/login_helper'
require 'support/feature_spec/new_post_helper'

describe 'Member can create a draft post and see' do
  before :each do
    FeatureSpecLoginHelper.new(self).register_and_login
    data = PostHelperSupport::PostCreatorData.new post_status: 'draft'
    FeatureSpecNewPostHelper.new(self, data).create_image_post
  end

  it 'the confirmation flash message' do
    expect(page).to have_text 'Post added!'
  end

  it 'the "well" area where posts should be displayed is not empty' do
    well = page.find('.well').native
    expect(well).not_to have(0).children
  end

  describe 'the newly-entered article details, including' do
    it 'the post title' do
      expect(page).to have_selector 'article > header > h3', @post_title
    end

    it 'the post timestamp' do
      expect(page).to have_selector 'article > header > p > time'
    end

    it 'the post body' do
      expect(page).to have_selector 'article > figure > figcaption', @post_body
    end

    it 'the post image, inside a link to it' do
      selector = format 'article > figure > p > a > img[src="%s"]', @image_url
      expect(page).to have_selector selector
    end
  end # describe 'the newly-entered article details, including'
end # describe 'Member can create a valid image post and see'
