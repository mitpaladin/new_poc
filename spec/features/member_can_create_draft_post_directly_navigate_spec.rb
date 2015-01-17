
require 'spec_helper'

require 'support/feature_spec/login_helper'
require 'support/feature_spec/new_post_helper'

describe 'Member can create a draft post and' do

  before :each do
    FeatureSpecLoginHelper.new(self).register_and_login
    data = PostHelperSupport::PostCreatorData.new post_status: 'draft'
    FeatureSpecNewPostHelper.new(self, data).create_image_post
  end

  it 'see the confirmation flash message' do
    expect(page).to have_text 'Post added!'
  end

  it 'directly navigate to the newly-entered post page' do
    visit post_path(@post_title.parameterize)
  end

  describe 'the newly-entered article details, including' do
    before :each do
      visit post_path(@post_title.parameterize)
    end

    it 'the post title' do
      expect(page).to have_selector '.page-header > h1', @post_title
    end

    it 'the author byline' do
      expected = %(by #{@user_name})
      selector = '.page-header > h1 > small > i'
      expect(page).to have_selector selector, expected
    end

    it 'the post body, properly formatted as HTML in the :figcaption tag' do
      expected = Newpoc::Services::MarkdownHtmlConverter.new.to_html @post_body
      actual = page.find('figcaption').native.children.first.to_html
      expect(actual).to eq expected
    end
  end # describe 'the newly-entered article details, including'
end # describe 'Member can create a draft post and'
