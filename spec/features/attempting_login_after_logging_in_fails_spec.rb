
require 'spec_helper'

require 'support/feature_spec/login_helper'

describe 'Attempting to login after already being logged in fails and' do
  let(:landing_page_header) { 'Watching Paint Dry' }

  before :each do
    FeatureSpecLoginHelper.new(self).register_and_login
  end

  it 'displays an "Already logged in!" alert' do
    visit new_session_path
    expected = "User '#{@user_name}' is already logged in!"
    expect(page).to have_css '.alert.alert-danger', text: expected
  end
end # describe 'Attempting to login after already being logged in fails and'
