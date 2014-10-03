
require 'spec_helper'

require 'support/feature_spec/login_helper'
require 'support/feature_spec/new_post_helper'

shared_examples 'cannot visit the post' do
  it 'by directly visiting the post path' do
    visit post_path(@post_slug)
    expected = 'You are not authorized to perform this action.'
    selector = 'div.alert.alert-error.alert-dismissable'
    expect(page).to have_selector selector, text: expected
  end
end

describe 'a draft post is' do
  before :each do
    @login_helper = FeatureSpecLoginHelper.new(self)
    @login_helper.register_and_login
    @data = PostHelperSupport::PostCreatorData.new post_status: 'draft'
    helper = FeatureSpecNewPostHelper.new self, @data
    helper.create_image_post
  end

  it 'accessible to its author' do
    visit root_path
    visit post_path(@post_slug)
    expect(page).to have_selector '.page-header > h1', @post_title
    expected = %(by #{@user_name})
    expect(page).to have_selector '.page-header > h1 > small > i', expected
  end

  describe 'not accessible to' do
    before :each do
      @login_helper.logout
    end

    describe 'the Guest User' do
      it_behaves_like 'cannot visit the post'
    end # describe 'the Guest User'

    describe 'a user other than the author' do
      before :each do
        @login_helper.step
        @login_helper.register_and_login
      end

      it_behaves_like 'cannot visit the post'
    end # describe 'a user other than the author'
  end # describe 'not editable by'
end # describe 'a draft post is'
