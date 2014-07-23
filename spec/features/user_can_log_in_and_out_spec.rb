
require 'spec_helper'

require 'support/feature_spec_login_helper'

describe 'User can' do
  let(:landing_page_header) { 'Watching Paint Dry' }

  before :each do
    @fsh = FeatureSpecLoginHelper.new(self)
    @fsh.register
  end

  it 'login' do
    within(:css, 'ul.navbar-nav') do
      click_link 'Log in'
    end
    fill_in 'Name', with: @user_name
    fill_in 'Password', with: @user_password
    click_button 'Log In'
    expect(page).to have_content landing_page_header
    expect(page).to have_css '.alert.alert-success', text: 'Logged in!'
    expect(page).to have_content "Hello, #{@user_name}!"
  end

  it 'logout' do
    @fsh.login
    within(:css, 'ul.navbar-nav') do
      click_link 'Log out'
    end
    expect(page).to have_css '.alert.alert-success', text: 'Logged out!'
    expect(page).to have_content 'Hello, Guest User!'
  end
end # describe 'User can log in and out'
