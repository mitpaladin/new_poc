
require_relative 'body_builder_base'

# Namespace containing all application-defined entities.
module Entity
  # The Post class encapsulates post-related domain logic of our "fancy" blog.
  # It delegates or defers implementation-specific details such as persistence,
  # user interface, etc.
  class Post
    # Presentation-ish methods used by current Post entity API.
    module Extensions
      # Presentation-oriented "decorator" methods and support.
      module Presentation
        # Body-builder class for text posts
        class TextBodyBuilder < BodyBuilderBase
          def build(post)
            markdown_converter.to_html post.body
          end
        end # class Entity::Post::Extensions::Presentation::TextBodyBuilder
      end
    end
  end # class Entity::Post
end
