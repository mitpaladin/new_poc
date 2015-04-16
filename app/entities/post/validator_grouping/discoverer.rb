
# Namespace containing all application-defined entities.
module Entity
  # The Post class encapsulates post-related domain logic of our "fancy" blog.
  # It delegates or defers implementation-specific details such as persistence,
  # user interface, etc.
  class Post
    # Isolates validation objects and groups them together so that an entity
    # can simply delegate `#errors` and `#valid` to an instance of this class,
    # and not change when a new validator is added or an existing one changed.
    # It also supports adding new validators that quack like the existing ones
    # (attribute-based initialisation with `#errors` and `#valid?` methods).
    class ValidatorGrouping
      # Enumerates validation classes and produces a hash of instances of each.
      class Discoverer
        extend Forwardable

        def initialize(source_obj)
          @namespace = namespace_based_on source_obj
          @classes = find_classes
        end

        def_delegators :@classes, :each, :[]

        private

        attr_reader :namespace

        def find_classes
          {}.tap do |classes|
            namespaced_constants.each do |const_sym|
              class_sym = namespaced_sym_for const_sym
              classes[index_for(const_sym)] = class_sym
            end
          end
        end

        def index_for(sym)
          # gsub is to convert eg, `ImageUrl` to `image_url`
          sym.to_s
            .gsub(/([A-Z])/) { |s| '_' + s.downcase }[1..-1]
            .to_sym
        end

        def namespace_based_on(source_obj)
          source_obj.class.parent.const_get :Validators
        end

        def namespaced_constants
          namespace.constants.select do |candidate|
            namespaced_sym_for(candidate).is_a? Class
          end
        end

        def namespaced_sym_for(sym)
          str = namespace.to_s + '::' + sym.to_s
          str.constantize
        end
      end # class Entity::Post::ValidatorGrouping::Discoverer
    end # class Entity::Post::ValidatorGrouping
  end # class Entity::Post
end
