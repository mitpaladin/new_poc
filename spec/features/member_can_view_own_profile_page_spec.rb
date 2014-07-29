
require 'spec_helper'

require 'support/feature_spec_login_helper'

describe 'Member can view own profile page' do
  before :each do
    @login_helper = FeatureSpecLoginHelper.new(self)
    @login_helper.register_and_login
    # visit root_path
    within(:css, 'ul.navbar-nav') do
      click_link 'View your profile'
    end
  end

  it 'and see own name in profile header' do
    assert_selector 'h1', text: "Profile Page for #{@user_name}"
  end

  it 'and see biodata as entered' do
    assert_selector '.panel-body', text: @user_bio
  end
end # describe 'Member can view own profile page'
