
require 'spec_helper'

require 'support/feature_spec/login_helper'

describe 'Member can view own profile page' do
  before :each do
    FeatureSpecLoginHelper.new(self).register_and_login
    within(:css, 'ul.navbar-nav') do
      click_link 'View your profile'
    end
  end

  it 'and see own name in profile header' do
    assert_selector 'h1', text: "Profile Page for #{@user_name}"
  end

  it 'and see biodata as entered' do
    # @user_bio currently has one italicised content fragment in ordinary text
    parts = @user_bio.match(/(.+?)\*(.+?)\*(.+)/).to_a.slice(1..3)
    assert_selector '.panel-body', text: parts.join
  end
end # describe 'Member can view own profile page'
