
module Newpoc
  module Entity
    # Domain entity for a user of the system.
    class User
      module Internals
        # Validates user name string.
        class NameValidator
          attr_reader :errors

          def initialize(name)
            @name = name
            @errors = []
          end

          def validate
            check_for_spaces_at_ends
            check_for_invalid_whitespace
            check_for_adjacent_whitespace
            self
          end

          def add_errors_to_model(model)
            @errors.each { |message| model.errors.add :name, message }
            self
          end

          private

          attr_reader :name

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

          def check_for_adjacent_whitespace
            return if name.to_s.strip == name.to_s.strip.gsub(/\s{2,}/, '?')
            @errors << 'may not have adjacent whitespace'
            self
          end

          def check_for_invalid_whitespace
            expected = name.to_s.strip.gsub(/ {2,}/, ' ')
            return if expected == expected.gsub(/\s/, ' ')
            @errors << 'may not have whitespace other than spaces'
            self
          end

          def check_for_spaces_at_ends
            return if name.to_s == name.to_s.strip
            add_error_if_whitespace :leading
            add_error_if_whitespace :trailing
            self
          end
        end # class Newpoc::Entity::User::Internals::NameValidator
      end # module Newpoc::Entity::User::Internals
    end # class Newpoc::Entity::User
  end # module Newpoc::Entity
end # module Newpoc
