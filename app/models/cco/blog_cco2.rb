
require 'blo/blog_data_boundary'

module CCO
  # Second-generation CCO for Blogs. Does not (presently) subclass Base.
  class BlogCCO2
    def self.from_entity(entity, _post_callback = ->(_post) {})
      # We only support a single blog at present, so this is easy
      ret = BlogData.first
      ret.title = entity.title
      ret.subtitle = entity.subtitle
      ret
    end

    def self.to_entity(impl)
      ret = Blog.new
      ::BLO::BlogDataBoundary.new(impl).entries.each do |entry|
        ret.entries << entry
      end
      ret
    end
  end # class CCO::Blog
end # module CCO
