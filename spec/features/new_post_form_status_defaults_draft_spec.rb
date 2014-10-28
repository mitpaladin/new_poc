
require 'spec_helper'

require 'support/feature_spec/login_helper'

xdescribe '"New Post" form has' do
  before :each do
    FeatureSpecLoginHelper.new(self).register_and_login
    visit new_post_path
  end

  it '"post status" field that defaults to "draft"' do
    expect(page).to have_field 'post_data_post_status', with: 'draft'
  end
end # describe '"New Post" form has'
