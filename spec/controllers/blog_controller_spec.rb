
require 'spec_helper'

describe BlogController do
  describe :routing.to_s, type: :routing do
    it { expect(get '/blog').to route_to 'blog#index' }
    it { expect(get '/blog/blog/new').to_not be_routable }
    it { expect(post '/blog/blog').to_not be_routable }
    it { expect(get '/blog/blog/1').to_not be_routable }
    it { expect(get '/blog/blog/edit').to_not be_routable }
    it { expect(put '/blog/blog/1').to_not be_routable }
    it { expect(delete '/blog/blog/1').to_not be_routable }
  end

  describe :helpers.to_s do
    it { expect(blog_index_path).to eq('/blog') }
  end

  describe "GET 'index'" do

    before :each do
      get :index
    end

    it 'returns http success' do
      response.should be_success
    end

    it 'renders the index template' do
      expect(response).to render_template 'index'
    end

    describe 'assigns a "blog" controller variable' do

      before :each do
        @blog = assigns 'blog'
      end

      describe 'that' do
        after :each do
          expect(@blog.send @field).to eq @expected
        end

        it 'has the expected title' do
          @expected = 'Watching Paint Dry'
          @field = :title
        end

        it 'has the expected subtitle' do
          @expected = 'The trusted source for drying paint news and opinion'
          @field = :subtitle
        end
      end # describe 'that'

      it 'that is decorated with a BlogDataDecorator' do
        expect(@blog).to be_decorated_with(BlogDataDecorator)
      end

      # No tests for entries; the blog *implementation model* knows no entries!

    end # describe 'assigns a "blog" controller variable'
  end # describe "GET 'index'"
end
