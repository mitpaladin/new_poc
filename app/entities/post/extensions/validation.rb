
require_relative 'validation/internals'

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
        # Helper module defines module methods for Validations.
        module ValidationExtensions
          def add_validation_class_methods(base)
            base.class.instance_eval do
              attr_reader :errors

              # Needed for ActiveModel::Errors to work.

              def lookup_ancestors
                [self]
              end

              def human_attribute_name(attr, _options = {})
                attr.to_s.humanize
              end
            end
          end
        end # module Entity::Post::Extensions::Validation::ValidationExtensions
        private_constant :ValidationInternals, :ValidationExtensions
        include ValidationInternals
        extend ValidationExtensions
        extend ActiveModel::Naming

        def self.extended(base)
          base.instance_eval do
            @errors = ActiveModel::Errors.new self
          end
          add_validation_class_methods base
        end

        def valid?
          valid_title? && valid_author_name? && body_or_image_post?
        end

        # Needed for ActiveModel::Errors to work.

        def read_attribute_for_validation(attr)
          send attr
        end
      end # module Entity::Post::Extensions::Validation
    end
  end # class Entity::Post
end
