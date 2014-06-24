
require 'spec_helper'

require 'post_creator_and_publisher'

# Module DSO contains our Domain Service Objects, aka "interactors".
module DSO
  describe PostCreatorAndPublisher do

    let(:klass) { PostCreatorAndPublisher }

    describe 'succeeds when called with valid parameters, such that' do
      let(:blog) { BlogData.first.to_param }
      let(:post_params) { FactoryGirl.attributes_for :post_datum }
      let(:params) { { post_data: post_params, blog: blog } }

      it 'no error is raised' do
        expect { klass.run! params: params }.to_not raise_error
      end

      it 'returns a Post instance' do
        expect(klass.run! params: params).to be_a Post
      end

      describe 'returns a Post instance that has' do
        let(:post) { klass.run! params: params }

        it 'the correct title' do
          expect(post.title).to eq post_params[:title]
        end

        it 'the correct body' do
          expect(post.body).to eq post_params[:body]
        end

        it 'been published' do
          expect(post).to be_published
        end
      end # describe 'returns a Post instance that has'
    end # describe 'succeeds when called with valid parameters, such that'

    describe 'fails when called with' do
    end # describe 'fails when called with'
  end # describe DSO::PostCreatorPublisher
end # module DSO
