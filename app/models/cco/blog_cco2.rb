
module CCO
  # Second-generation CCO for Blogs. Does not (presently) subclass Base.
  class BlogCCO2
    def self.from_entity(_entity, _post_callback = ->(_post) {})
    end

    def self.to_entity(_impl)
      Blog.new
    end
  end # class CCO::Blog
end # module CCO
