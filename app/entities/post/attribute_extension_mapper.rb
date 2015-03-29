
# Namespace containing all application-defined entities.
module Entity
  # The Post class encapsulates post-related domain logic of our "fancy" blog.
  # It delegates or defers implementation-specific details such as persistence,
  # user interface, etc.
  class Post
    # Iterate extension modules building attribute mappings.
    class AttributeExtensionMapper
      def initialize(extension_container = Extensions)
        @extension_container = extension_container
      end

      def build
        by_module = build_mapping.tap do |mapping|
          yield mapping if block_given?
        end
        remap by_module
      end

      private

      def build_mapping
        ret = {}
        extension_container.constants.each do |module_sym|
          ret[module_sym] = get_attributes_for module_sym
        end
        ret.delete_if { |_k, v| v.empty? }
      end

      def extension_for_module(module_key)
        return :core if module_key == :core
        extension_container.const_get module_key
      end

      def get_attributes_for(module_sym)
        extension = extension_container.const_get module_sym
        return [] unless extension.respond_to? :supported_attributes
        extension.supported_attributes
      end

      def remap(by_module)
        {}.tap do |by_attribute|
          by_module.each_key do |module_key|
            by_module[module_key].each do |attribute|
              by_attribute[attribute] = extension_for_module module_key
            end
          end
        end
      end

      attr_reader :extension_container
    end # class Entity::Post::AttributeExtensionMapper
  end # class Entity::Post
end
