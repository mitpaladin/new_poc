
require 'awesome_print'

module DSO
  module Support
    # Value object for passing into post-creation interactors, etc.
    class PostCreationParam
      attr_reader :status

      def initialize(basic_attribs = {}, status = 'draft')
        @attribs = {}
        attrib_keys.each do |key|
          @attribs[key] = basic_attribs.fetch key, ''
        end
        @status = valid_status_from status
      end

      def to_h
        @attribs
      end

      private

      def attrib_keys
        [:title, :body, :image_url, :author_name]
      end

      def default_status
        'draft'
      end

      def valid_status_from(input_str)
        str = input_str.strip
        return str if valid_status_strings.include? str
        default_status
      end

      def valid_status_strings
        %w(draft public)
      end
    end
  end # module DSO::Support
end # module DSO
