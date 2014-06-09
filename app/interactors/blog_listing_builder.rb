
require 'fancy-open-struct'

module DSO
  # Build list of information about a blog for presentation: title, subtitle,
  # entry data.
  class BlogListingBuilder < ActiveInteraction::Base
    interface :blog, methods: [:title, :subtitle, :entries]

    # Eventually, this is where we'd sort and filter posts being presented to
    # the user (public/private/draft posts; ordering, limiting, etc.) We "fake
    # it" by returning a FancyOpenStruct with *a copy of* the details.
    def execute
      ret = init_return_value_from blog
      blog.entries.each { |post| ret.entries << copy_entry_from(post) }
      ret
    end

    private

    def copy_entry_from(post)
      FancyOpenStruct.new title: post.title, body: post.body
    end

    def init_return_value_from(blog)
      ret = FancyOpenStruct.new
      ret.title = blog.title
      ret.subtitle = blog.subtitle
      ret.entries = []
      ret
    end
  end # class DSO::BlogListingBuilder
end # module DSO
