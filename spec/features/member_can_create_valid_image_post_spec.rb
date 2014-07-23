
require 'spec_helper'

require 'support/feature_spec_login_helper'

describe 'Member can create a valid image post' do

  before :each do
    FeatureSpecLoginHelper.new(self).register_and_login
    visit new_post_path
  end

  it 'by entering the title and body text' do
    post_title = 'This is a Title!'
    post_body = "Isn't this a lovely image?"
    image_url = 'http://fc01.deviantart.net/fs70/f/2014/113/e/6/' \
        'dreaming_of_another_reality_by_razielmb-d7fgl3s.png'

    fill_in 'Title', with: post_title
    fill_in 'Body', with: post_body
    fill_in 'Image URL', with: image_url
    click_on 'Create Post'
    expect(page).to have_text 'Post added!'
    expect(page).to have_selector 'article > header > h3', post_title
    expect(page).to have_selector 'article > header > p > time'
    expect(page).to have_selector 'article > figure > figcaption', post_body
    selector = format 'article > figure > img[src="%s"]', image_url
    expect(page).to have_selector selector
  end

end # describe 'Member can create a valid image post'
