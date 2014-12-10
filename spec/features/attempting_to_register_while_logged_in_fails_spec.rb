
require 'spec_helper'

require 'support/feature_spec/login_helper'

describe 'Attempting to register after already being logged in fails and' do
  before :each do
    FeatureSpecLoginHelper.new(self).register_and_login
  end

  it 'displays an "Already logged in!" alert' do
    visit new_user_path
    expected = "Already logged in as #{@user_name}!"
    expect(page).to have_css '.alert.alert-danger', text: expected
  end
end # describe 'Attempting to register after already being logged in fails and'
