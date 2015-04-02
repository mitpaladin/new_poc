
# require 'active_model/validations'

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
        # A lovely, simple error-tracking mechanism and, being part of
        # Active*Model*, should not be too tightly bound to Rails ActiveRecord
        # internals, you'd think. And you'd apparently be wrong.
        # include ActiveModel::Validations

        def valid?
          valid_title? && valid_author_name? && body_or_image_post?
        end

        private

        def author_name_present?
          string_attr_present? :author_name, author_name
        end

        def body_or_image_post?
          return true if body.to_s.strip.present?
          image_url.to_s.strip.present?
        end

        def registered_author?
          return true unless author_name == 'Guest User'
          # errors.add :author_name, 'must not be the Guest User'
          false
        end

        def string_attr_present(_attr_sym, attr)
          return true if attr.present? && attr == attr.strip
          # message = "#{attr_sym.to_s.humanize} must be present and must not" \
          #   ' contain leading or trailing whitespace'
          # errors.add attr_sym, message
          false
        end

        def valid_author_name?
          author_name_present? && registered_author?
        end

        def valid_title?
          string_attr_presetn? :title, title
        end
      end # module Entity::Post::Extensions::Validation
    end
  end # class Entity::Post
end
