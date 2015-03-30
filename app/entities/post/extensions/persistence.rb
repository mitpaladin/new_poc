
# Namespace containing all application-defined entities.
module Entity
  # The Post class encapsulates post-related domain logic of our "fancy" blog.
  # It delegates or defers implementation-specific details such as persistence,
  # user interface, etc.
  class Post
    # Extensions to Post entity beyond core attribute manipulation.
    #
    # Unlike extensions such as Validation or Presentation, this module is not
    # (ordinarily) explicitly loaded by a `Post` method needing to perform an
    # action, but in response to attributes being specified to the `#initialize`
    # method of `Post`. See `Post#initialize` and `Post#method_missing` to get a
    # sense of how this works.
    #
    # IMPORTANT NOTE: This extension, like all optional extensions, uses the
    # `original_attributes` instance method on the extending class to get the
    # attribute values specified *to* that class' `#initialize` method. It also
    # calls that class' `#add_attributes_set` instance method.
    module Extensions
      # Persistence-state attribute readers pertinent to Post entities.
      module Persistence
        # Value object containing attribute definitions used by this class.
        class PersistenceAttributes < ValueObject::Base
          has_fields :created_at, :slug, :updated_at
        end
        private_constant :PersistenceAttributes

        def self.extended(base)
          base.instance_eval do
            new_values = PersistenceAttributes.new original_attributes
            add_attributes_set :persistence, new_values
          end
        end

        def self.supported_attributes
          PersistenceAttributes.fields
        end

        def persisted?
          slug.present?
        end
      end # module Entity::Post::Extensions::Persistence
    end
  end # class Entity::Post
end
