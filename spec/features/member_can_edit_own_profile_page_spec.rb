
require 'spec_helper'

require 'support/feature_spec/login_helper'

describe 'Member can edit own profile' do
  before :each do
    FeatureSpecLoginHelper.new(self).register_and_login
    visit user_path(@user_name.parameterize)
    @old_bio = page.find('.panel > .panel-body').native.to_html
    within(:css, 'h1.bio') do
      click_link 'Edit Your Profile'
    end
    @new_bio = @user_bio + ', Updated.'
    fill_in 'Profile Summary (Optional)', with: @new_bio
    click_on 'Update Profile'
  end

  it 'and see the updated biodata in her profile' do
    rendered_bio = page.find('.panel-body').native.to_html
    expect(rendered_bio).not_to eq @old_bio
  end

  it 'and see the updated-profile alert message' do
    alert = page.find('.main > .alert').native
    message = 'You successfully updated your profile'
    expect(alert.children.last.content).to eq message
  end
end # describe 'Member can edit own profile'
