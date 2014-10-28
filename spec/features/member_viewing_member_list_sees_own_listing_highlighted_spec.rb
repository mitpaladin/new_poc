
require 'spec_helper'

xdescribe 'A member viewing the member list' do
  let(:user_count) { 3 }

  before :each do
    user_data = []
    user_obj = FeatureSpecLoginHelper.new(self)
    user_count.times do
      user_data << Marshal.load(Marshal.dump user_obj.data)
      user_obj.register_and_login
      user_obj.logout
      user_obj.step
    end
    user_obj.data = Marshal.load(Marshal.dump user_data.last)
    user_obj.login
    visit users_path
  end

  it 'sees no active/current-user highlight' do
    expect(page).to have_selector 'h1', 'All Registered Users'
    expect(page).to have_selector 'tbody > tr', count: user_count
    expect(page).to have_selector 'tbody > tr.info'
  end
end
