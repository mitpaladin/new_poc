
module DSO
  # Build list of entries associated with a Blog *entity*.
  class BlogEntityPostLoader < ActiveInteraction::Base
    model :blog

    def execute
      blog.entries.clear
      PostData.all.each do |impl|
        blog.entries << CCO::PostCCO.to_entity(impl)
      end
      blog.entries
    end
  end # class DSO::BlogEntityPostLoader
end # module DSO
