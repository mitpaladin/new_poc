
module CCO
  class PostCCO
    # Convert PostData implementation object to Post entity.
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
        [:author_name, :body, :image_url, :pubdate, :slug, :title]
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
  end # class CCO::PostCCO
end # module CCO
