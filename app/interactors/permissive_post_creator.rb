
module DSO
  # Create a new post on a blog, isolating the caller (which is normally the
  # controller) from any knowledge of exactly how that happens.
  class PermissivePostCreator < ActiveInteraction::Base
    interface :blog, methods: [:new_post]
    hash :params_in do
      hash :post_data do
        string :title, default: '', strip: true
        string :body, default: '', strip: true
      end
    end

    def execute
      blog.new_post params_in[:post_data]
    end
  end
end # module DSO
