
require 'spec_helper'

require 'support/feature_spec/login_helper'
require 'support/feature_spec/new_post_helper'

xdescribe 'Member can create a draft post and' do

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

  it 'the newly-entered article details' do
    visit post_path(@post_title.parameterize)
    expect(page).to have_selector '.page-header > h1', @post_title
    expected = %(by #{@user_name})
    expect(page).to have_selector '.page-header > h1 > small > i', expected

    # There's got to be an easier way to match Markdown content...
    md = Redcarpet::Markdown.new Redcarpet::Render::HTML.new
    pbody = Nokogiri.parse(md.render(@post_body)).children.first
    # FWIW, be advised that we're matching markup converted to text here...
    expect(page.find('figcaption')).to have_content pbody.inner_text
  end

end # describe 'Member can create a draft post and'
