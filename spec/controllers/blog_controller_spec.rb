
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
      get 'index'
      response.should be_success
    end
  end
end
