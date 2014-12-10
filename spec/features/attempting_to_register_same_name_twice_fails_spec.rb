
require 'spec_helper'

require 'support/feature_spec/login_helper'

describe 'Attempting to register the same user name twice' do
  let(:helper) { FeatureSpecLoginHelper.new self, user_name: user_name }
  let(:user_name) { 'Joe Palooka' }
  let(:user_slug) { user_name.parameterize }

  before :each do
    helper.register
    helper.register
  end

  describe 'fails and' do

    it 'displays the correct alert error message' do
      expected = "Name is invalid: A record identified by slug '#{user_slug}'" \
        ' already exists!'
      expect(page).to have_css '.alert.alert-danger ul li', text: expected
    end

    it 'stays on the "Sign Up" page' do
      expect(page).to have_css 'legend', text: 'Sign Up'
    end

    it 'highlights the name field as the error' do
      error_css = '.controls .field_with_errors #user_data_name'
      expect(page).to have_css error_css
    end
  end # describe 'fails and'
end # describe 'Attempting to register the same user name twice'
