
require 'spec_helper'

xdescribe 'User can view the landing page' do

  before :each do
    visit root_path
  end

  it 'and see the title and subtitle' do
    blog_title = 'Watching Paint Dry'
    blog_subtitle = 'The trusted source for drying paint news and opinion'

    expect(page).to have_content blog_title
    expect(page).to have_content blog_subtitle
  end

end # describe 'User can view the landing page'
