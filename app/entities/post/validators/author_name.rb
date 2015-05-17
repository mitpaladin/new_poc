
require 'contracts'

require 'post_factory'

# Namespace containing all application-defined entities.
module Entity
  # The Post class encapsulates post-related domain logic of our "fancy" blog.
  # It delegates or defers implementation-specific details such as persistence,
  # user interface, etc.
  class Post
    # Validators for various fields.
    module Validators
      # Validates author-name attribute, providing #valid? and #errors public
      # methods that work generally as you'd expect.
      class AuthorName
        include Contracts

        Contract RespondTo[:to_hash] => AuthorName
        def initialize(attributes)
          @author_name = attributes.to_hash[:author_name]
          @errors = []
          self
        end

        Contract None => ArrayOf[HashOf[Symbol, String]]
        def errors
          valid?
          @errors
        end

        Contract None => Bool
        def valid?
          @errors = []
          present
          not_blank
          no_leading_whitespace
          no_trailing_whitespace
          no_consecutive_whitespace
          not_guest_user
          @errors.empty?
        end

        private

        Contract String => AuthorName
        def add_error(message)
          entry = { author_name: message }
          @errors.push entry
          self
        end

        Contract None => String
        def author_name
          @author_name.to_s
        end

        Contract None => Bool
        def blank?
          author_name.gsub(/\A\W+?\z/, ':::') == ':::'
        end

        Contract None => AuthorName
        def no_leading_whitespace
          return self if author_name == author_name.lstrip || blank?
          add_error 'must not contain leading whitespace'
        end

        Contract None => AuthorName
        def no_consecutive_whitespace
          stripped = author_name.strip
          spaces_ok = stripped == stripped.gsub(/\s+/, ' ')
          return self if spaces_ok || blank?
          add_error 'must not have consecutive internal whitespace'
        end

        Contract None => AuthorName
        def no_trailing_whitespace
          return self if author_name == author_name.rstrip || blank?
          add_error 'must not contain trailing whitespace'
        end

        Contract None => AuthorName
        def not_blank
          return self unless blank?
          add_error 'must not be blank'
        end

        Contract None => AuthorName
        def not_guest_user
          return self unless author_name.strip.downcase == 'guest user'
          add_error 'must be a registered user'
        end

        Contract None => AuthorName
        def present
          return self if @author_name
          add_error 'must be present'
        end
      end # class Entity::Post::Validators::AuthorName
    end
  end # class Entity::Post
end
