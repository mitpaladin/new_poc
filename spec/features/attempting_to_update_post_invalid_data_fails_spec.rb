
require 'spec_helper'

require 'support/feature_spec/login_helper'
require 'support/feature_spec/new_post_helper'

describe 'Attepting to update a post with invalid data' do
  before :each do
    FeatureSpecLoginHelper.new(self).register_and_login
    FeatureSpecNewPostHelper.new(self).create_text_post
  end

  describe 'fails and' do
    before :each do
      visit edit_post_path(@post_slug)
      fill_in 'Body', with: ''
      click_button 'Update Post'
    end

    it 'displays the correct alert error message' do
      expected = 'Body must be specified if image URL is omitted'
      expect(page).to have_css '.alert.alert-danger', text: expected
    end
  end # describe 'fails and'
end
