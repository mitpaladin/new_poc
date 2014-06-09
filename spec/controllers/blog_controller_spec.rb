
require 'spec_helper'

describe BlogController do
  describe :routing.to_s, type: :routing do
    it { expect(get '/blog').to route_to 'blog#index' }
  end

  describe :helpers.to_s do
    it { expect(blog_index_path).to eq('/blog') }
  end

  describe "GET 'index'" do
    it 'returns http success' do
      get :index
      response.should be_success
    end

    it 'renders the index template' do
      get :index
      expect(response).to render_template 'index'
    end

    describe 'assigns a "blog" controller variable that' do

      after :each do
        get :index
        blog = assigns 'blog'
        expect(blog.send @field).to eq @expected
      end

      it 'has the expected title' do
        @expected = 'Watching Paint Dry'
        @field = :title
      end

      it 'has the expected subtitle' do
        @expected = 'The trusted source for drying paint news and opinion'
        @field = :subtitle
      end

      it 'has the expected entries' do
        @expected = []
        @field = :entries
      end
    end # describe 'assigns a "blog" controller variable that'
  end # describe "GET 'index'"
end
