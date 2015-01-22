
require 'spec_helper'

require 'support/feature_spec/login_helper'

describe 'Attempting to register a new user fails with data invalid because' do
  after :each do
    helper = FeatureSpecLoginHelper.new self, user_name: @user_name
    helper.register
    expect(page).to have_css '.alert.alert-danger'
    expected = '1 error prevented this User from being saved'
    expect(page.find '.alert h2').to have_text expected
    expect(page.find '.alert > ul > li').to have_text @message
  end

  it 'it has leading spaces' do
    @user_name = '  Some Body'
    @message = 'Name may not have leading whitespace'
  end

  it 'it has trailing spaces' do
    @user_name = 'Some Body  '
    @message = 'Name may not have trailing whitespace'
  end

  it 'it has repeated internal spaces' do
    @user_name = 'Some   Body'
    @message = 'Name may not have adjacent whitespace'
  end

  it 'it contains invalid whitespace characters' do
    @user_name = "Some\tBody"
    @message = 'Name may not have whitespace other than spaces'
  end
end # describe 'Attempting to register a new user fails with data invalid...'
