
require 'spec_helper'

require 'support/feature_spec/login_helper'

describe 'Member can enter' do

  let(:error_message)   { '1 error prevented this PostDao from being saved:' }
  let(:post_body)       { 'The Body is six feet under, nine edge down.' }
  let(:post_title)      { 'Clear Title to This Post' }
  let(:post_url)        { 'http://www.example.com/foo.png' }

  before :each do
    FeatureSpecLoginHelper.new(self).register_and_login
    visit new_post_path
  end

  it 'image URL on New Post form' do
    fill_in 'Title', with: post_title
    fill_in 'Body', with: post_body
    fill_in 'Image URL', with: post_url
    click_on 'Create Post'
    expect(page).to_not have_text error_message
  end

end # describe 'Member can enter'
