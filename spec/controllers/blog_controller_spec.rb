
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
    it 'returns http success' do
      get :index
      response.should be_success
    end

    it 'renders the index template' do
      get :index
      expect(response).to render_template 'index'
    end

    describe 'assigns a "blog" controller variable' do

      describe 'that' do
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
      end # describe 'that'

      context 'that, when no posts have been published,' do

        it 'has an empty "entries" collection' do
          get :index
          blog = assigns 'blog'
          entries = blog.send :entries
          expect(entries).to be_an Array
          expect(entries).to be_empty
        end
      end # context 'that, when no posts have been published,'

      context 'that, when published posts exist for the blog,' do
        before :each do
          FactoryGirl.create_list :post_datum, 5
        end

        it 'has the posts in its "entries" collection' do
          get :index
          blog = assigns 'blog'
          entries = blog.send :entries
          expect(entries).to have(5).entries
          entries.each do |entry|
            expect(entry.title).to match(/\ATest Title Number \d+\z/)
            expect(entry.body).to eq 'The Body'
          end
        end
      end # context 'that, when published posts exist for the blog,'
    end # describe 'assigns a "blog" controller variable'
  end # describe "GET 'index'"
end
