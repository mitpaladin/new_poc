
require 'spec_helper'

describe 'A Guest User viewing the member list' do
  let(:user_count) { 3 }

  before :each do
    user_obj = FeatureSpecLoginHelper.new(self)
    user_count.times do
      user_obj.register_and_login
      user_obj.logout
      user_obj.step
    end
    visit users_path
  end

  it 'sees no active/current-user highlight' do
    expect(page).to have_selector 'h1', 'All Registered Users'
    expect(page).to have_selector 'tbody > tr', count: user_count
    expect(page).not_to have_selector 'tbody > tr.info'
  end
end
