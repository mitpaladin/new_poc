
require 'spec_helper'

require 'support/feature_spec_login_helper'

describe 'Member cannot create post without' do

  let(:error_detail)    { "Title can't be blank" }
  let(:error_message)   { '1 error prevented this PostData from being saved:' }
  let(:post_body)       { 'The Body is six feet under, nine edge down.' }
  let(:success_report)  { 'Post added!' }

  before :each do
    FeatureSpecLoginHelper.new(self).register_and_login
    visit new_post_path
  end

  it 'title' do
    expect(page).to_not have_text error_message
    fill_in 'Body', with: post_body
    click_on 'Create Post'
    expect(page).to have_text error_message
    expect(page).to have_text error_detail
    expect(page).to_not have_text success_report
  end

end # describe 'Member cannot create post without'
