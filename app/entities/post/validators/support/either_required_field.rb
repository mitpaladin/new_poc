
require 'contracts'

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
          include Contracts

          INIT_CONTRACT_INPUTS = {
            attributes: RespondTo[:to_hash],
            primary: Symbol,
            other: Symbol
          }

          Contract INIT_CONTRACT_INPUTS => EitherRequiredField
          def initialize(attributes:, primary:, other:)
            @primary = primary
            @other = other
            @main_attribute = attributes.to_hash[primary].to_s.strip
            @other_empty = attributes.to_hash[other].to_s.strip.empty?
            @errors = []
            self
          end

          Contract None => ArrayOf[Maybe[Hash]]
          def errors
            valid?
            @errors
          end

          Contract None => Bool
          def valid?
            @errors = []
            return true unless both_fields_empty?
            @errors.push error_entry
            false
          end

          private

          attr_reader :main_attribute, :other_empty, :other, :primary

          Contract None => Bool
          def both_fields_empty?
            @main_attribute.empty? && other_empty
          end

          Contract None => HashOf[Symbol, String]
          def error_entry
            # FIXME: old message
            message = "must be specified if #{other_name} is omitted"
            # proposed new message
            # message = "may not be empty if #{other_name} is missing or empty"
            {}.tap do |ret|
              ret[primary] = message
            end
          end

          Contract None => String
          def other_name
            other.to_s.humanize.downcase.gsub(/ url$/, ' URL')
          end
        end # class Entity::Post::Validators::Support::EitherRequiredField
      end
    end
  end # class Entity::Post
end
