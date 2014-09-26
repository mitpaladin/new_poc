
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
    # Convert PostData implementation object to Post entity.
    # FIXME: Move to own file when we replace PostCCO with PostCCO2.
    class ImplConverter
      def initialize(impl, params)
        @impl, @params = impl, params
      end

      def convert
        build_attribs
        setup_post
      end

      protected

      attr_accessor :attribs
      attr_reader :impl, :params

      private

      def attrib_names
        [:author_name, :body, :image_url, :slug, :title]
      end

      def build_attribs
        @attribs = {}
        attrib_names.each do |attrib|
          @attribs[attrib] = impl.attributes[attrib.to_s]
        end
      end

      def parse_params
        blog = params.fetch :blog, nil
        add_to_blog = params.fetch :add_to_blog, !blog.nil?
        [blog, add_to_blog]
      end

      def setup_post
        blog, add_to_blog = parse_params
        post = Post.new attribs
        if add_to_blog
          blog.add_entry post
        else
          post.blog = blog
        end
        post
      end
    end # class PostCCO2::ImplConverter

    def self.from_entity(_entity, _params = {})
    end

    def self.to_entity(impl, params = {})
      ImplConverter.new(impl, params).convert
    end
  end # class CCO::PostCCO2
end # module CCO
