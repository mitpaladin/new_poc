
# Namespace containing all application-defined entities.
module Entity
  # The Post class encapsulates post-related domain logic of our "fancy" blog.
  # It delegates or defers implementation-specific details such as persistence,
  # user interface, etc.
  class Post
    # Extensions to Post entity beyond core attribute manipulation.
    module Extensions
      # Validation logic pertinent to Post entities.
      module Validation
        def valid?
          valid_title? && valid_author_name? && body_or_image_post?
        end

        private

        def body_or_image_post?
          return true if body.to_s.strip.present?
          image_url.to_s.strip.present?
        end

        def registered_author?
          author_name != 'Guest User'
        end

        def valid_author_name?
          author_name.present? && author_name == author_name.strip &&
            registered_author?
        end

        def valid_title?
          title.present? && title == title.strip
        end
      end # module Entity::Post::Extensions::Validation
    end
  end # class Entity::Post
end
