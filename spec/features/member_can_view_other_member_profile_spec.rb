
require 'spec_helper'

require 'support/feature_spec/login_helper'

xdescribe 'Member can view the profile of another member' do
  before :each do
    login_helper = FeatureSpecLoginHelper.new(self)
    login_helper.register_and_login
    @author_name = @user_name
    login_helper.logout
    login_helper.step
    login_helper.register_and_login
    visit user_path(@author_name.parameterize)
  end

  it 'and see profile content' do
    assert_selector 'h1', text: "Profile Page for #{@author_name}"
  end

  it 'and not see edit-profile button next to profile header' do
    refute_selector 'h1 button'
  end
end # describe 'Guest can view the profile of a registered user'
