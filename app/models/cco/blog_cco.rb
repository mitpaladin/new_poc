
module CCO
  # Cross-layer conversion object for Blogs. API (slightly) tailored from Base.
  class BlogCCO < Base
    def self.to_entity(impl)
      new_entity = Blog.new
      params = FancyOpenStruct.new impl: impl, new_entity: new_entity
      super params
    end

    # Exception raised by .from_entity until we actually need this feature.
    class UnsupportedConversionError < StandardError
    end

    def self.from_entity(_entity)
      fail UnsupportedConversionError,
           'Conversion from Blog entity unsupported at this time.'
      # super FancyOpenStruct.new entity: entity, new_impl: BlogData.new
    end
  end # class CCO::PostCCO
end # module CCO
