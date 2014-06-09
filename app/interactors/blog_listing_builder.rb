
module DSO
  # Build list of information about a blog for presentation: title, subtitle,
  # entry data.
  class BlogListingBuilder < ActiveInteraction::Base
    interface :blog, methods: [:title, :subtitle, :entries]

    # Eventually, this is where we'd sort and filter posts being presented to
    # the user (public/private/draft posts; ordering, limiting, etc.) We "fake
    # it" by returning an object with *a read-only copy of* the details.
    def execute
      Builder.new blog
    end

    # Why? So we can use attr_reader to lock down write access to attributes,
    # which OpenStruct/FancyOpenStruct don't support (intentionally).
    class Builder
      attr_reader :title, :subtitle, :entries

      def initialize(blog)
        @title = blog.title.freeze
        @subtitle = blog.subtitle.freeze
        @entries = copy_entries_from(blog)
        @entries.freeze # <mc_hammer>can't touch this</mc_hammer>
      end

      private

      # Information about a blog entry, currently only body and title.
      class Entry
        attr_reader :title, :body
        def initialize(post)
          @title = post.title.freeze
          @body = post.body.freeze
        end
      end # class DSO::BlogListingBuilder::Builder::Entry

      def copy_entries_from(blog)
        ret = []
        blog.entries.each { |post| ret << Entry.new(post) }
        ret
      end
    end # class DSO::BlogListingBuilder::Builder
  end # class DSO::BlogListingBuilder
end # module DSO
