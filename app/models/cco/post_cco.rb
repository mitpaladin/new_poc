
module CCO
  # Cross-layer conversion object for Posts. API (slightly) tailored from Base.
  class PostCCO < Base
    def self.to_entity(impl, blog = Blog.new)
      new_entity = blog.new_post
      params = FancyOpenStruct.new impl: impl, new_entity: new_entity
      super params
    end

    def self.from_entity(entity)
      super FancyOpenStruct.new entity: entity, new_impl: PostData.new
    end
  end # class CCO::PostCCO
end # module CCO
