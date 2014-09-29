
require_relative 'post_cco_support/impl_converter'

module CCO
  # Cross-layer conversion object for Posts, second go.
  # What went wrong with the first one? We're tripping over the trap that's been
  #       in the code since the early follow-the-Book days that equates
  #       publication of a Post, persistence of that Post, and associating a
  #       Post with a particular Blog. Here starts our (latest in never mind how
  #       long a series) attempt to get things working (more) properly. A NOTE
  #       from the original implementation still applies and is below.
  class PostCCO
    def self.from_entity(entity)
      PostData.new(entity.to_h).tap do |post|
        post.save! if entity.slug
      end
    end

    def self.to_entity(impl, params = {})
      ImplConverter.new(impl, params).convert
    end
  end # class CCO::PostCCO2
end # module CCO
