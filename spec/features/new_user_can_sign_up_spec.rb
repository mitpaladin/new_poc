
require 'spec_helper'

describe 'New user can sign up by visiting the "Sign Up" page and' do
  let(:landing_page_header) { 'Watching Paint Dry' }
  let(:text_of_button)      { 'Sign Up' }
  let(:text_of_navbar_link) { 'Sign up' }
  let(:thank_you)           { 'Thank you for signing up!' }
  let(:user_bio)            { 'I am what I am. You are what you eat.' }
  let(:user_email)          { 'jruser@example.com' }
  let(:user_name)           { 'J Random User' }
  let(:user_password)       { 's00persecret' }

  before :each do
    visit root_path
    within(:css, 'ul.navbar-nav') do
      click_link text_of_navbar_link
    end
  end

  it 'filling in the form' do
    fill_in 'Name', with: user_name
    fill_in 'Email', with: user_email
    fill_in 'Password', with: user_password
    fill_in 'Password confirmation', with: user_password
    fill_in 'Profile Summary (Optional)', with: user_bio
    click_button text_of_button
    expect(page).to have_content landing_page_header
    expect(page).to have_css '.alert.alert-success', text: thank_you
  end
end # describe 'New user can sign up'
