
module CCO
  # Cross-layer conversion object for Posts, second go.
  # What went wrong with the first one? We're tripping over the trap that's been
  #       in the code since the early follow-the-Book days that equates
  #       publication of a Post, persistence of that Post, and associating a
  #       Post with a particular Blog. Here starts our (latest in never mind how
  #       long a series) attempt to get things working (more) properly. A NOTE
  #       from the original implementation still applies and is below.
  # NOTE: To add a converted entity to a Blog instance, use #add_entry, *NOT*
  #       #new_post. The entity comes back thinking it's not attached to *any*
  #       Blog instance, which is almost certainly not what you want.
  #       You Have Been Warned.
  class PostCCO2
    def self.from_entity(_entity, _params = {})
    end

    def self.to_entity(impl, _params = {})
      attribs = {}
      [:author_name, :body, :image_url, :slug, :title].each do |method_sym|
        attribs[method_sym] = impl.attributes[method_sym.to_s]
      end
      Post.new attribs
    end
  end # class CCO::PostCCO2
end # module CCO
