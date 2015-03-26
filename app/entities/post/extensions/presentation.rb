
require_relative 'presentation/byline_builder'
require_relative 'presentation/image_body_builder'
require_relative 'presentation/text_body_builder'

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
        def self.extended(base)
          base.extend ClassMethods
        end

        def build_body
          build self
        end

        def build_byline
          BylineBuilder.new(self).to_html
        end

        def post_status
          return 'draft' unless pubdate
          'public'
        end

        # Class methods for presentation extensions; no instance state affected.
        module ClassMethods
          def build(entity)
            builder = body_builder_class_for(entity).new
            builder.build entity
          end

          def body_builder_class_for(entity)
            return ImageBodyBuilder if entity.image_url.present?
            TextBodyBuilder
          end
        end # module Entity::Post::Extensions::Presentation::ClassMethods
        private_constant :ClassMethods
      end # module Entity::Post::Extensions::Presentation
    end # module Entity::Post::Extensions
  end # class Entity::Post
end
