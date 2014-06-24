
require 'blog_selector'

module DSO
  # Create a new post on a blog, isolating the caller (which is normally the
  # controller) from any knowledge of exactly how that happens.
  class PermissivePostCreator < ActiveInteraction::Base
    hash :blog_params, default: {} do
      integer :id, default: 1
    end
    # interface :blog, methods: [:new_post]
    hash :params_in, default: {} do
      hash :post_data, default: {} do
        string :title, default: '', strip: true
        string :body, default: '', strip: true
      end
    end

    def execute
      the_blog = BlogSelector.run! blog_params: blog_params
      the_blog.new_post params_in[:post_data]
    end
  end
end # module DSO
