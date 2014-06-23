
require 'spec_helper'

describe 'Member cannot create post without' do

  let(:error_message) { '1 error prevented this PostData from being saved:' }
  let(:post_body)     { 'The Body is six feet under, nine edge down.' }

  before :each do
    visit new_post_path
  end

  it 'title' do
    fill_in 'Body', with: post_body
    click_on 'Create Post'
    expect(page).to have_text error_message
    expect(page).to have_text "Title can't be blank"
    expect(page).to_not have_text 'Post added!'
  end

end # describe 'Member cannot create post without'
