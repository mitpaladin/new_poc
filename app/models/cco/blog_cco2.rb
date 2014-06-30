
module CCO
  # Second-generation CCO for Blogs. Does not (presently) subclass Base.
  class BlogCCO2
    def self.from_entity(entity, post_callback = ->(_post) {})
      post_callback.call entity # bogus
    end

    def self.to_entity(_impl)
    end
  end # class CCO::Blog
end # module CCO
