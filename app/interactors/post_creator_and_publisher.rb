
require 'blog_post_adder'
require 'blog_selector'
require 'permissive_post_creator'

require_relative 'support/post_data_lambda'

# Module containing domain service-level objects, aka DSOs or interactors.
module DSO
  # Create and publish a new post on a blog, using other DSOs as workers.
  class PostCreatorAndPublisher < ActiveInteraction::Base
    hash :params do
      # NOTE: This is the blog ID as a Rails controller parameter (string).
      string :blog, default: '1'
      hash :post_data do
        POST_DATA_LAMBDA.call self
      end
    end

    def execute
      post = PermissivePostCreator.run! create_params
      BlogPostAdder.run!(post: post) if post.valid?
      post
    end

    private

    def create_params
      {
        blog_params: { id: params[:blog] },
        post_data:  params[:post_data]
      }
    end
  end # class DSO::PostCreatorAndPublisher
end # module DSO
