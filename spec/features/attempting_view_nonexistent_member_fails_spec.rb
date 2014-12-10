
require 'spec_helper'

describe 'Attempting to view the profile of a nonexistent user fails and' do
  let(:user_name) { 'nonexistent-user' }

  before :each do
    visit user_path user_name
  end

  it 'displays an "Cannot find user!" alert' do
    expected = "Cannot find user identified by slug #{user_name}!"
    expect(page).to have_css '.alert', text: expected
  end

  it 'redirects to the user-list page' do
    expect(page).to have_css '.page-header > h1', text: 'All Registered Users'
  end
end # describe 'Attempting to view the profile of a nonexistent user fails and'
