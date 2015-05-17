
require 'contracts'

# Namespace containing all application-defined entities.
module Entity
  # The `User` class is the *core business-logic entity* modelling users in the
  # system. The core class encapsulates logic not specific to one use case or
  # group of use cases (such as authorisation). It also establishes a namespace
  # which encapsulates more specific entity-oriented responsibilities.
  class User
    # Class responsible for adding field validation to a User entity.
    class ValidatorSupport
      # Internal classes used exclusively by ValidatorSupport class.
      module Internals
        # Validates user name string following rules documented at #validate.
        class NameValidator
          include Contracts

          attr_reader :errors

          # Initialise a new instance by setting the `name` attribute to the
          # specified value. Calling with `nil` will simply return false from
          # `#validate`, but should be accepted here unmolested.
          # @param name [String] User name to be validated by this instance.
          Contract Maybe[String] => NameValidator
          def initialize(name)
            @name = name
            @errors = []
            self
          end

          # Validates user name by three separate, related rules.
          # A user name MUST NOT have:
          #
          # 1. leading or trailing whitespace characters;
          # 2. whitespace characters other than the space character
          # 3. consecutive whitespace characters within its text ("Bad   Value")
          #
          # Calls methods to perform each validation step and add an appropriate
          # message to an internal list if that validation step fails.
          Contract None => NameValidator
          def validate
            check_for_spaces_at_ends
            check_for_invalid_whitespace
            check_for_adjacent_whitespace
            self
          end

          # Adds error messages generated on behalf of #validate to an
          # ActiveModel instance passed in as a parameter.
          # @param Model instance quacking like ActiveModel::Validations.
          Contract RespondTo[:errors] => NameValidator
          def add_errors_to_model(model)
            @errors.each { |message| model.errors.add :name, message }
            self
          end

          private

          attr_reader :name

          # Adds an error message to the internal list if the `name` attribute
          # has either leading or trailing whitespace as specified by the
          # parameter.
          # @param strip_where [Symbol] Either `:leading`, to check for spaces
          #                             at the beginning of the `name`
          #                             attribute, OR `:trailing` to check at
          #                             the end.
          Contract Symbol => NameValidator
          def add_error_if_whitespace(strip_where)
            strips = {
              leading: :lstrip,
              trailing: :rstrip
            }
            error_message = format 'may not have %s whitespace',
                                   strip_where.to_s
            @errors << error_message if name != name.send(strips[strip_where])
            self
          end

          # Adds an error message to the internal list if the `name` attribute
          # contains two or more consecutive internal whitespace characters.
          Contract None => NameValidator
          def check_for_adjacent_whitespace
            cleaned_name = name.to_s.strip.gsub(/\s{2,}/, '?')
            return self if name.to_s.strip == cleaned_name
            @errors << 'may not have adjacent whitespace'
            self
          end

          # Adds an error message to the internal list if the `name` attribute
          # contains whitespace *other than* the space character. (`' '`)
          Contract None => NameValidator
          def check_for_invalid_whitespace
            expected = name.to_s.strip.gsub(/ {2,}/, ' ')
            return self if expected == expected.gsub(/\s/, ' ')
            @errors << 'may not have whitespace other than spaces'
            self
          end

          # Calls the internal #add_error_if_whitespace method to check first
          # for leading, then for trailing, whitespace at the ends of the `name`
          # attributes.
          Contract None => NameValidator
          def check_for_spaces_at_ends
            return self if name.to_s == name.to_s.strip
            add_error_if_whitespace :leading
            add_error_if_whitespace :trailing
            self
          end
        end # class Entity::User::Internals::NameValidator
      end # module Entity::User::ValidatorSupport::Internals
    end # class Entity::User::ValidatorSupport
  end # class Entity::User
end # module Entity
