
require_relative 'post/byline_builder'
require_relative 'post/image_body_builder'
require_relative 'post/text_body_builder'

# Namespace containing all application-defined entities.
module Entity
  # The Post class encapsulates post-related domain logic of our "fancy" blog.
  # It delegates or defers implementation-specific details such as persistence,
  # user interface, etc.
  class Post
    # Presentation-ish methods used by current Post entity API.
    module BodyHelper
      def self.build(entity)
        builder = body_builder_class_for(entity).new
        builder.build entity
      end

      def self.body_builder_class_for(entity)
        if entity.image_url.present?
          Entity::Post::ImageBodyBuilder
        else
          Entity::Post::TextBodyBuilder
        end
      end
    end # module Post::BodyHelper
    private_constant :BodyHelper

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

    def build_body
      BodyHelper.build self
    end

    def build_byline
      BylineBuilder.new(self).to_html
    end

    def persisted?
      attributes[:slug].present?
    end

    def post_status
      return 'draft' unless pubdate
      'public'
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
