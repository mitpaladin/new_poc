
require 'spec_helper'

describe 'New user can sign up by visiting the "Sign Up" page and' do
  let(:landing_page_header) { 'Watching Paint Dry' }

  before :each do
    visit root_path
    within(:css, '.navbar-nav') do
      click_link 'Sign Up'
    end
  end

  it 'filling in the form' do
    fill_in 'Name', with: 'J Random User'
    fill_in 'Email', with: 'jruser@example.com'
    fill_in 'Password', with: 's00persecret'
    fill_in 'Password confirmation', with: 's00persecret'
    fill_in 'Profile Summary (Optional)', with: 'This is me.'
    click_button 'Sign Up'
    expect(page).to have_content landing_page_header
    expect(page).to have_content 'Thank you for signing up!'
    expect(page).to have_css '.alert.alert-success'
  end

end # describe 'New user can sign up'
