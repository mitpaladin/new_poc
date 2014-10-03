
require 'spec_helper'

require 'support/feature_spec/login_helper'
require 'support/feature_spec/new_post_helper'

def expected(title)
  %("#{title}" Published DRAFT)
end

def list_item_css
  '#contrib-row > ul > li'
end

def link_css(title)
  "a[href='/posts/#{title.parameterize}']"
end

describe 'a draft post' do
  before :each do
    @login_helper = FeatureSpecLoginHelper.new(self)
    @login_helper.register_and_login
    @data = PostHelperSupport::PostCreatorData.new post_status: 'draft'
    helper = FeatureSpecNewPostHelper.new self, @data
    helper.create_image_post
  end

  it 'is shown to the author in his profile page article listing' do
    visit user_path(@user_name.parameterize)
    list_item = page.find list_item_css
    link = list_item.find link_css(@post_title)
    expect(link).to have_text expected(@post_title)
  end

  describe "is not shown in the author's profile page article history to" do
    before :each do
      author_name = Marshal.load(Marshal.dump @user_name)
      @login_helper.logout
      visit user_path(author_name.parameterize)
    end

    it 'the Guest User' do
      expect(page).not_to have_content @post_title
    end

    it 'another registered user' do
      expect(page).not_to have_content @post_title
    end
  end # describe "is not shown in the author's profile page article history to"
end
