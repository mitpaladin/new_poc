
require_relative 'post/extensions/presentation'
require_relative 'post/extensions/validation'

# Namespace containing all application-defined entities.
module Entity
  # The Post class encapsulates post-related domain logic of our "fancy" blog.
  # It delegates or defers implementation-specific details such as persistence,
  # user interface, etc.
  class Post
    attr_reader :author_name, :body, :created_at, :image_url, :pubdate, :slug,
                :title, :updated_at

    def extend_with_presentation
      extend Extensions::Presentation
    end

    def extend_with_validation
      extend Extensions::Validation
    end

    def initialize(attributes)
      attrib_keys.each do |attrib|
        instance_variable_set "@#{attrib}".to_sym, attributes[attrib]
      end
    end

    def attributes
      {}.tap do |ret|
        attrib_keys.each do |attrib|
          ret[attrib] = instance_variable_get "@#{attrib}".to_sym
        end
      end
    end

    def persisted?
      attributes[:slug].present?
    end

    private

    def attrib_keys
      [:author_name, :body, :created_at, :image_url, :pubdate, :slug, :title,
       :updated_at]
    end
  end # class Entity::Post
end
