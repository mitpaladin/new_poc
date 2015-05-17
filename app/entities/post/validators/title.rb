
# Namespace containing all application-defined entities.
module Entity
  # The Post class encapsulates post-related domain logic of our "fancy" blog.
  # It delegates or defers implementation-specific details such as persistence,
  # user interface, etc.
  class Post
    # Validators for various fields.
    module Validators
      # Validates title attribute, providing #valid? and #errors public methods
      # that work generally as you'd expect.
      class Title
        include Contracts

        Contract RespondTo[:to_hash] => Title
        def initialize(attributes)
          @title = attributes.to_hash[:title]
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
          return false unless present?
          not_blank?
          no_leading_whitespace?
          no_trailing_whitespace?
          no_extra_whitespace?
          @errors.empty?
        end

        private

        attr_reader :title

        Contract String => Title
        def add_error(message)
          entry = { title: message }
          @errors.push entry
          self
        end

        Contract Symbol => String
        def message_for(id_sym)
          {
            no_extra: 'must not have extra internal whitespace',
            no_leading: 'must not have leading whitespace',
            no_trailing: 'must not have trailing whitespace',
            not_blank: 'must not be blank',
            present: "can't be blank"
          }[id_sym]
        end

        Contract Symbol, Proc => Bool
        def validate(message_id, &_block)
          return true if yield(title)
          add_error message_for(message_id)
          false
        end

        Contract None => Bool
        def no_leading_whitespace?
          validate(:no_leading) do |title|
            title.to_s.rstrip == title.to_s.rstrip.lstrip
          end
        end

        Contract None => Bool
        def no_extra_whitespace?
          validate(:no_extra) do |title|
            title.to_s.strip == title.to_s.strip.gsub(/\s+/, ' ')
          end
        end

        Contract None => Bool
        def no_trailing_whitespace?
          validate(:no_trailing) do|title|
            title.to_s.lstrip == title.to_s.strip
          end
        end

        Contract None => Bool
        def not_blank?
          validate(:not_blank) { |title| title.to_s.strip.present? }
        end

        Contract None => Bool
        def present?
          validate(:present) { |title| title }
        end
      end # class Entity::Post::TitleValidator
    end
  end # class Entity::Post
end
