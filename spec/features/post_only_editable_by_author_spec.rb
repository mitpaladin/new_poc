
require 'spec_helper'

require 'support/feature_spec/login_helper'
require 'support/feature_spec/new_post_helper'

shared_examples 'cannot edit the post' do |expected|
  it 'since no "Edit <article title>" button is shown' do
    visit post_path(@post_slug)
    text = "Edit '#{@post_title}'"
    expect(page).not_to have_link text, edit_post_path(@post_slug)
  end

  it 'by directly visiting the edit-post path' do
    visit edit_post_path(@post_slug)
    expected ||= "User #{@user_name} is not the author of this post!"
    selector = 'div.alert.alert-error.alert-dismissable'
    expect(page).to have_selector selector, text: expected
  end
end

describe 'A published post is' do

  before :each do
    @login_helper = FeatureSpecLoginHelper.new(self)
    @login_helper.register_and_login
    @data = PostHelperSupport::PostCreatorData.new
    helper = FeatureSpecNewPostHelper.new self, @data
    helper.create_image_post
  end

  describe 'not editable by' do
    before :each do
      @login_helper.logout
    end

    describe 'the Guest User' do
      expected = 'Not logged in as a registered user!'
      it_behaves_like 'cannot edit the post', expected
    end # describe 'the Guest User'

    describe 'a user other than the author' do
      before :each do
        @login_helper.step
        @login_helper.register_and_login
      end

      it_behaves_like 'cannot edit the post'
    end # describe 'a user other than the author'
  end # describe 'not editable by'
end # describe 'A published post is'
