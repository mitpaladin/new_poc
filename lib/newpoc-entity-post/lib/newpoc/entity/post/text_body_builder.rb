
module Newpoc
  module Entity
    # a Post is the domain entity for a blog-type post, with title, body, etc.
    class Post
      module SupportClasses
        # Build text post body.
        class TextBodyBuilder
          def build(obj)
            body_markup obj.body
          end

          private

          # NOTE: This method *must* be mocked by unit tests, as the converter
          #       is now part of a different Gem (that can't be required as a
          #       dependency at present).
          def body_markup(markup)
            require 'newpoc/services/markdown_html_converter'
            Newpoc::Services::MarkdownHtmlConverter.new.to_html(markup)
          end
        end # class Newpoc::Entity::Post::SupportClasses::TextBodyBuilder
      end # module Newpoc::Entity::Post::SupportClasses
    end # class Newpoc::Entity::Post
  end # module Newpoc::Entity
end # module Newpoc
