
require 'spec_helper'

require 'support/feature_spec/login_helper'
require 'support/feature_spec/new_post_helper'

shared_examples 'cannot edit the post' do
  it 'since no "Edit <article title>" button is shown' do
    visit post_path(@post_slug)
    text = "Edit '#{@post_title}'"
    expect(page).not_to have_link text, edit_post_path(@post_slug)
  end

  it 'by directly visiting the edit-post path' do
    visit edit_post_path(@post_slug)
    expected = 'You are not authorized to perform this action.'
    selector = 'div.alert.alert-error.alert-dismissable'
    expect(page).to have_selector selector, text: expected
  end
end

xdescribe 'A published post is' do

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
      it_behaves_like 'cannot edit the post'
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
