
require 'spec_helper'

describe 'Attempting to login as a nonexistent user fails and' do
  let(:user_name) { 'nonexistent-user' }
  let(:password) { 'password' }

  before :each do
    visit new_session_path
    fill_in 'Name', with: user_name
    fill_in 'Password', with: password
    click_button 'Log In'
  end

  it 'displays an "Invalid user name or password" alert' do
    expect(page).to have_css '.alert', text: 'Invalid user name or password'
  end

  it 'redisplays the login page' do
    expect(page).to have_selector 'legend', text: 'Log In'
  end
end # describe 'Attempting to login as a nonexistent user fails and'
