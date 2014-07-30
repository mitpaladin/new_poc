
require 'spec_helper'

require 'support/feature_spec/login_helper'
require 'support/feature_spec/new_post_helper'

describe 'Member can publish articles and' do

  before :each do
    FeatureSpecLoginHelper.new(self).register_and_login
    FeatureSpecNewPostHelper.new(self).create_image_post
    within(:css, 'ul.navbar-nav') do
      click_link 'View your profile'
    end
  end

  it 'view links to them on own profile page' do
    item = find :css, '.list-group .list-group-item'
    expect(item.tag_name).to eq 'li'
    link = item.find 'a'
    expect(link['href']).to eq "/posts/#{@post_title.parameterize}"
    expected = [
      %("#{@post_title}"),
      'Published',
      Time.now.localtime.strftime('%c %Z')
    ].join ' '
    expect(link).to have_text expected
  end

end # describe 'Member can publish articles and'
