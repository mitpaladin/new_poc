
require 'spec_helper'

require 'support/feature_spec/login_helper'

describe 'Guest user attempting to create a new post fails and' do
  let(:flash_alert) { 'Not logged in as a registered user!' }

  before :each do
    visit new_post_path
  end

  it 'displays a "Not logged in!" alert' do
    expect(page).to have_css '.alert.alert-danger', text: flash_alert
  end

  it 'redirects to the landing page' do
    expect(page.current_path).to eq root_path
  end
end # describe 'Guest user attempting to create a new post fails and'
