
require 'spec_helper'

describe 'blog/index.html.slim' do

  before :each do
    render
  end

  describe 'has the correct content, including' do

    it 'a top-level header with the correct text' do
      assert_select 'h1', text: 'Watching Paint Dry'
    end

    it 'a second-level header with the correct text' do
      assert_select 'h2', 'The trusted source for paint drying news and opinion'
    end

    it 'a dummy paragraph' do
      assert_select 'p', 'Find me in app/views/blog/index.html.slim'
    end

  end # describe 'has the correct content, including'
end
