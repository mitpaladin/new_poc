
require 'contracts'

require 'app_contracts'

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
        include Contracts

        SOURCE_CONTRACT = Or[RespondTo[:to_hash], RespondTo[:attributes]]

        Contract SOURCE_CONTRACT => Attributes
        def initialize(post)
          @attributes = value_object_from(attributes_for post)
          self
        end

        def_delegators :@attributes, :author_name, :pubdate, :updated_at

        private

        Contract SOURCE_CONTRACT => RespondTo[:to_hash]
        def attribute_source_for(post)
          return post if post.respond_to? :to_hash
          post.attributes
        end

        Contract SOURCE_CONTRACT => HashOf[Symbol, Any]
        def attributes_for(post)
          attribute_source_for(post).to_hash.symbolize_keys
        end

        Contract None => AlwaysRaises
        def author_name_missing!
          fail 'post must have an :author_name attribute value'
        end

        Contract HashOf[Symbol, Any] => ActiveSupport::TimeWithZone
        def updated_time_for(attrs)
          return attrs[:updated_at] if attrs[:updated_at]
          return attrs[:pubdate] if attrs[:pubdate]
          Time.zone.now
        end

        Contract HashOf[Symbol, Any] => ValueObject::Base
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
