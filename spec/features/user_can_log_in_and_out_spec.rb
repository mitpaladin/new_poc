
require 'spec_helper'

def register_new_user(name, email, password, bio)
  visit root_path
  within(:css, 'ul.navbar-nav') do
    click_link 'Sign up'
  end
  fill_in 'Name', with: name
  fill_in 'Email', with: email
  fill_in 'Password', with: password
  fill_in 'Password confirmation', with: password
  fill_in 'Profile Summary (Optional)', with: bio
  click_button 'Sign Up'
end

describe 'User can log in and out' do
  let(:landing_page_header) { 'Watching Paint Dry' }
  let(:user_bio)            { 'I am what I am. You are what you eat.' }
  let(:user_email)          { 'jruser@example.com' }
  let(:user_name)           { 'J Random User' }
  let(:user_password)       { 's00persecret' }

  before :each do
    register_new_user user_name, user_email, user_password, user_bio
    within(:css, 'ul.navbar-nav') do
      click_link 'Log in'
    end
  end

  it 'using the menus' do
    fill_in 'Name', with: user_name
    fill_in 'Password', with: user_password
    click_button 'Log In'
    expect(page).to have_content landing_page_header
    expect(page).to have_css '.alert.alert-success', text: 'Logged in!'
    within(:css, 'ul.navbar-nav') do
      click_link 'Log out'
    end
    expect(page).to have_css '.alert.alert-success', text: 'Logged out!'
  end

end # describe 'User can log in and out'
