
require 'spec_helper'

describe 'User can view the member-list page' do

  before :each do
    visit root_path
  end

  it 'by navigating to it using the menu' do
    within :css, 'ul.navbar-nav' do
      click_link 'All members'
    end
    expect(page).to have_selector 'h1', 'All Registered Users'
  end
end
