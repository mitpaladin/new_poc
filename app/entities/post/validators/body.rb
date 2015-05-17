
require_relative 'support/either_required_field'

# Namespace containing all application-defined entities.
module Entity
  # The Post class encapsulates post-related domain logic of our "fancy" blog.
  # It delegates or defers implementation-specific details such as persistence,
  # user interface, etc.
  class Post
    # Validators for various fields.
    module Validators
      # Validates body attribute, providing #valid? and #errors public methods
      # that work generally as you'd expect.
      class Body < Support::EitherRequiredField
        include Contracts

        Contract RespondTo[:to_hash] => Body
        def initialize(attributes)
          super attributes: attributes, primary: :body, other: :image_url
          self
        end
      end # class Entity::Post::Validators::Body
    end
  end # class Entity::Post
end
