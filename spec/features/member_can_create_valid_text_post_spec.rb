
require 'spec_helper'

require 'support/feature_spec/login_helper'
require 'support/feature_spec/new_post_helper'

describe 'Member can create a valid text post and see' do

  before :each do
    FeatureSpecLoginHelper.new(self).register_and_login
    FeatureSpecNewPostHelper.new(self).create_text_post
  end

  it 'the confirmation flash message' do
    expect(page).to have_text 'Post added!'
  end

  it 'the newly-entered article details' do
    expect(page).to have_selector 'article > header > h3', @post_title
    expect(page).to have_selector 'article > header > p > time'
    expect(page).to have_selector 'article > p', @post_body
  end

end # describe 'Member can create a valid image post and see'
