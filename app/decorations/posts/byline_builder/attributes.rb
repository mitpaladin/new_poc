
# POROs that act as presentational support for entities.
module Decorations
  # Decorations for `Post` entities. D'oh!
  module Posts
    # Builds an HTML fragment (a paragraph) containing a timestamp and author-
    # name attribution.
    class BylineBuilder
      # Encapsulates attributes passed in from a "Post", used by main class.
      class Attributes
        extend Forwardable

        def initialize(post)
          @attributes = value_object_from(attributes_for post)
        end

        def_delegators :@attributes, :author_name, :pubdate, :updated_at

        private

        def attribute_source_for(post)
          return post if post.respond_to? :to_hash
          return post.attributes if post.respond_to? :attributes
          message = 'Post must expose its attributes either through an' \
            ' #attributes or #to_hash method'
          fail message
        end

        def attributes_for(post)
          attribute_source_for(post).to_hash.symbolize_keys
        end

        def author_name_missing!
          fail 'post must have an :author_name attribute value'
        end

        def updated_time_for(attrs)
          return attrs[:updated_at] if attrs[:updated_at]
          return attrs[:pubdate] if attrs[:pubdate]
          Time.zone.now
        end

        def value_object_from(attrs)
          author_name_missing! unless attrs[:author_name]
          attrs[:updated_at] = updated_time_for(attrs)
          Class.new(ValueObject::Base) do
            has_fields :author_name, :pubdate, :updated_at
          end.new attrs
        end
      end # class Decorations::Posts::BylineBuilder::Attributes
      # private_constant :Attributes
    end # class Decorations::Posts::BylineBuilder
  end
end
