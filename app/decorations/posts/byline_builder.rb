
require 'contracts'

require 'timestamp_builder'

require_relative 'byline_builder/attributes'
require_relative 'byline_builder/markup_builder'

# POROs that act as presentational support for entities.
module Decorations
  # Decorations for `Post` entities. D'oh!
  module Posts
    # Builds an HTML fragment (a paragraph) containing a timestamp and author-
    # name attribution.
    class BylineBuilder
      include Contracts

      # Validation contract for BylineBuilder.build
      class InitContract
        module Internals
          def ___values_for(source)
            values = source.to_hash.symbolize_keys
            [values[:author_name], values[:pubdate]]
          end

          def ___validate(obj)
            ___values_for obj
          rescue NoMethodError
            begin
              ___values_for obj.attributes
            rescue NoMethodError
              nil
            end
          end
        end
        private_constant :Internals
        extend Internals

        def self.valid?(obj)
          author_name, pubdate = ___validate obj
          return false unless author_name.is_a? String
          # nil is allowed for draft posts
          pubdate.nil? || pubdate.is_a?(ActiveSupport::TimeWithZone)
        end

        def self.to_s
          'an object responding to #to_hash or #attributes#to_hash with' \
            ' values for attributes :author_name and :pubdate'
        end
      end

      Contract InitContract => String
      def self.build(post)
        MarkupBuilder.new(Attributes.new post).to_html
      end
    end # class Decorations::Posts::BylineBuilder
  end
end
