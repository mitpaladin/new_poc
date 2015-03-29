
# Namespace containing all application-defined entities.
module Entity
  # The Post class encapsulates post-related domain logic of our "fancy" blog.
  # It delegates or defers implementation-specific details such as persistence,
  # user interface, etc.
  class Post
    # Extensions to Post entity beyond core attribute manipulation.
    module Extensions
      # Persistence-state attribute readers pertinent to Post entities.
      module Persistence
        extend Forwardable

        # Value object containing attribute definitions used by this class.
        class PersistenceAttributes < ValueObject::Base
          has_fields :created_at, :slug, :updated_at
        end
        private_constant :PersistenceAttributes

        def self.extended(base)
          base.instance_eval do
            @attributes[:persistence] = PersistenceAttributes.new @attributes_in
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
