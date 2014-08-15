
require 'spec_helper'

require 'support/feature_spec/login_helper'

describe 'Member can view own profile page' do
  before :each do
    FeatureSpecLoginHelper.new(self).register_and_login
    @profile_header = ['Profile Page for', @user_name].join ' '
    within(:css, 'ul.navbar-nav') do
      click_link 'View your profile'
    end
  end

  it 'and see own name in profile header' do
    assert_selector 'h1', text: @profile_header
  end

  it 'and see edit-profile link next to profile header' do
    href = edit_user_path(@user_name.parameterize)
    assert_selector "h1 button[href='#{href}']",
                    text: 'Edit Your Profile'
  end

  it 'and see biodata as entered' do
    # @user_bio currently has one emphasised Markdown fragment in ordinary text
    parts = @user_bio.match(/(.+?)\*(.+?)\*(.+)/).to_a.slice(1..3)
    # Find the entire @user_bio markup in the panel
    expected = [parts[0], '<em>', parts[1], '</em>', parts[2]].join
    bio = page.find('.panel-body p').native # get the Nokogiri element node
    expect(bio.to_html).to eq ['<p>', '</p>'].join(expected)
  end
end # describe 'Member can view own profile page'
