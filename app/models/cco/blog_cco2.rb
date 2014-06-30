
require 'blo/blog_data_boundary'

module CCO
  # Second-generation CCO for Blogs. Does not (presently) subclass Base.
  class BlogCCO2
    def self.from_entity(_entity, _post_callback = ->(_post) {})
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
