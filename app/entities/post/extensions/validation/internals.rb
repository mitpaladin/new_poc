
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
        # because private methods in a module just don't work
        module ValidationInternals
          # Common validation for string attributes w/o whitespace on ends.
          class StringAttrValidator
            def initialize(attr_sym, errors)
              @attr_sym = attr_sym
              @errors = errors
            end

            def validate(value)
              return true if value.present? && value == value.strip
              errors.add attr_sym, message
              false
            end

            private

            attr_reader :attr_sym, :errors

            def message
              'must be present and must not contain leading or trailing' \
                ' whitespace'
            end
          end # class ...::Validation::ValidationInternals::StringAttrValidator
          private_constant :StringAttrValidator

          def author_name_present?
            string_attr_present? :author_name, author_name
          end

          def body_or_image_post?
            ret = body.to_s.strip.present? || image_url.to_s.strip.present?
            return true if ret
            errors.add :body, 'must be present if image URL is missing'
          end

          def registered_author?
            return true unless author_name == 'Guest User'
            errors.add :author_name, 'must not be the Guest User'
            false
          end

          def valid_author_name?
            validator =  StringAttrValidator.new(:author_name, errors)
            validator.validate(author_name) && registered_author?
          end

          def valid_title?
            StringAttrValidator.new(:title, errors).validate title
          end
        end # module Entity::Post::Extensions::Validation::ValidationInternals
      end
    end
  end # class Entity::Post
end
