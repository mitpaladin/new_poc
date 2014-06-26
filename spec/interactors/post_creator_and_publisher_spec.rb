
require 'spec_helper'

require 'post_creator_and_publisher'

# Module DSO contains our Domain Service Objects, aka "interactors".
module DSO
  describe PostCreatorAndPublisher do

    let(:klass) { PostCreatorAndPublisher }
    let(:blog) { BlogData.first.to_param }
    let(:post_params) { FactoryGirl.attributes_for :post_datum }
    let(:params) { { post_data: post_params, blog: blog } }

    describe 'succeeds when called with valid parameters, such that' do
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

        it 'the correct image URL' do
          expect(post.image_url).to eq post_params[:image_url]
        end

        it 'been published' do
          expect(post).to be_published
        end
      end # describe 'returns a Post instance that has'
    end # describe 'succeeds when called with valid parameters, such that'

    describe 'reports errors when called with' do

      describe 'both an empty post body and empty image URL, so that' do
        let(:post) do
          post_params[:body] = ''
          post_params[:image_url] = ''
          klass.run! params: params
        end

        it 'the post reports itself as invalid' do
          expect(post).to_not be_valid
        end

        it 'the expected error is shown to have been detected' do
          message = 'Body must be present if image URL is not present'
          expect(post).to have(1).error_message
          expect(post.error_messages).to include message
        end

        it 'the post has not been published' do
          expect(post).to_not be_published
        end
      end # describe 'both an empty post body and empty image URL, so that'
    end # describe 'fails when called with'
  end # describe DSO::PostCreatorPublisher
end # module DSO
