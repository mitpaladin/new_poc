
require 'spec_helper'

require 'support/feature_spec/login_helper'
require 'support/feature_spec/new_post_helper'

describe 'A user profile cannot be updated with invalid data; it' do
  before :each do
    FeatureSpecLoginHelper.new(self).register_and_login
    visit edit_user_path(@user_name.parameterize)
    fill_in 'Password', with: 'password'
    fill_in 'Password confirmation', with: 'password confirmation'
    click_on 'Update Profile'
  end

  it 'displays the correct error message' do
    expected = "Password confirmation doesn't match Password"
    expect(page).to have_css '.alert', text: expected
  end

  it 'redisplays the edit-user form' do
    expect(page).to have_css 'legend', text: 'Edit your Profile'
  end
end # describe 'A user profile cannot be updated with invalid data; it'
