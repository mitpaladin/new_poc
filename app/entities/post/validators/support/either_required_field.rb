
# Namespace containing all application-defined entities.
module Entity
  # The Post class encapsulates post-related domain logic of our "fancy" blog.
  # It delegates or defers implementation-specific details such as persistence,
  # user interface, etc.
  class Post
    # Validators for various fields.
    module Validators
      # The `Support` module exists to move classes out of the `Validators`
      # direct module namespace, so that globbing the latter only returns actual
      # field-level validators.
      module Support
        # Validates one field in the presence or absence of another, as with
        # body and image URL attributes.
        class EitherRequiredField
          def initialize(attributes:, primary:, other:)
            @primary = primary
            @other = other
            @main_attribute = attributes.to_hash[primary].to_s.strip
            @other_empty = attributes.to_hash[other].to_s.strip.empty?
            @errors = []
          end

          def errors
            valid?
            @errors
          end

          def valid?
            @errors = []
            return true unless both_fields_empty?
            @errors.push error_entry
            false
          end

          private

          attr_reader :main_attribute, :other_empty, :other, :primary

          def both_fields_empty?
            @main_attribute.empty? && other_empty
          end

          def error_entry
            message = "may not be empty if #{other_name} is missing or empty"
            {}.tap do |ret|
              ret[primary] = message
            end
          end

          def other_name
            other.to_s.humanize.downcase.gsub(/ url$/, ' URL')
          end
        end # class Entity::Post::Validators::Support::EitherRequiredField
      end
    end
  end # class Entity::Post
end
