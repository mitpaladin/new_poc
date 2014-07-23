
require 'spec_helper'

require 'support/feature_spec_login_helper'

describe '"New Post" form has correct' do
  before :each do
    FeatureSpecLoginHelper.new(self).register_and_login
    visit new_post_path
  end

  it 'button caption' do
    the_button = find 'input[name="commit"]'
    expect(the_button['value']).to eq 'Create Post'
    # expect(page).to have_button 'Create Post'
  end
end # describe '"New Post" form has correct'
