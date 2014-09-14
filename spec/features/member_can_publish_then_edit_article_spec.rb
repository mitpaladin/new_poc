
require 'spec_helper'

require 'support/feature_spec/login_helper'
require 'support/feature_spec/new_post_helper'

describe 'Member can publish articles and' do

  before :each do
    FeatureSpecLoginHelper.new(self).register_and_login
    @data = PostHelperSupport::PostCreatorData.new
    helper = FeatureSpecNewPostHelper.new self, @data
    helper.create_image_post
    visit post_path(@post_slug)
  end

  it 'view the "Edit <article title>" button on the article page' do
    text = "Edit '#{@post_title}'"
    expect(page).to have_link text, edit_post_path(@post_slug)
  end

  it 'view the "Edit article" page after clicking the button' do
    click_link "Edit '#{@post_title}'"
    expected_text = 'Update an Existing Post'
    expect(page).to have_selector 'form > legend', text: expected_text
  end

  it 'then edit the new article' do
    new_caption = 'Updated Body Text'
    click_link "Edit '#{@post_title}'"
    fill_in 'post_data_body', with: new_caption
    click_button 'Update Post'
    expected = "Article '#{@post_title}' successfully updated."
    selector = 'div.alert.alert-success.alert-dismissable'
    expect(page).to have_selector selector, text: expected
    expect(page).to have_selector 'figcaption > p', text: new_caption
  end
end # describe 'Member can publish articles and'
