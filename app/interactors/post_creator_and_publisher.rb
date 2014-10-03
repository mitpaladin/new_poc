
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
    string :post_status, default: 'draft', strip: true

    def execute
      post = PermissivePostCreator.run! create_params
      tweak_pubdate_for_status post
      BlogPostAdder.run!(add_params post) if post.valid?
      post
    end

    private

    def add_params(post)
      {
        post:   post,
        status: post_status
      }
    end

    def create_params
      {
        blog_params: { id: params[:blog] },
        post_data:  params[:post_data]
      }
    end

    def draft?
      post_status == 'draft'
    end

    def tweak_pubdate_for_status(post)
      post.pubdate = nil if draft?
      post.pubdate = Time.now unless draft?
      post
    end
  end # class DSO::PostCreatorAndPublisher
end # module DSO
