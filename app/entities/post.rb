
# Namespace containing all application-defined entities.
module Entity
  # The Post class encapsulates post-related domain logic of our "fancy" blog.
  # It delegates or defers implementation-specific details such as persistence,
  # user interface, etc.
  class Post
    attr_reader :author_name, :body, :created_at, :image_url, :pubdate, :slug,
                :title, :updated_at

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

    def valid?
      valid_title? && valid_author_name? && body_or_image_post?
    end

    private

    def attrib_keys
      [:author_name, :body, :created_at, :image_url, :pubdate, :slug, :title,
       :updated_at]
    end

    def body_or_image_post?
      return true if attributes[:body].to_s.strip.present?
      attributes[:image_url].to_s.strip.present?
    end

    def registered_author?
      attributes[:author_name] != 'Guest User'
    end

    def valid_author_name?
      name = attributes[:author_name]
      name.present? && name == name.strip && registered_author?
    end

    def valid_title?
      title = attributes[:title]
      title.present? && title == title.strip
    end
  end # class Entity::Post
end
