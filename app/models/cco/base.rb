
module CCO
  # Base cross-level conversion object. Converts from entity to implementation-
  # model instance and back.
  # NOTE: Assumes that all implementation model instances other than timestamps
  #       have one-for-one equivalent setters (attributes or methods) on the
  #       entity ("title" => #title, etc.).
  # NOTE: Assumes further that all instance variables on the entity have similar
  #       mapping to attributes on the implementation model.
  # This should suffice for our initial model/entity pairings (Post, Blog).
  class Base
    # Internal module containing support code for .from_entity and .to_entity.
    module Internal
      def self.set_attr_on(dest, name, value)
        method = (name + '=').to_sym
        dest.send(method, value) if dest.respond_to? method
      end
    end # module CCO::Base::Internal

    def self.from_entity(params)
      ret = params.new_impl
      entity = params.entity
      ivars = entity.instance_variables # e.g., [:@title, :@body, :@blog]
      ivars.each do |ivar|
        attr_value = entity.instance_variable_get ivar
        attr_name = ivar.to_s.split('@').last
        Internal.set_attr_on ret, attr_name, attr_value
      end # ivars.each do |ivar|
      ret.valid?  # trigger building of error messages for invalid record
      ret
    end

    def self.to_entity(params)
      impl = params.impl
      entity = params.new_entity
      attr_names = impl.attribute_names.delete_if { |s| s.match(/_at$/) }
      attr_names.each do |attr_name|
        Internal.set_attr_on entity, attr_name, impl[attr_name]
      end # attr_names.each do |attr_name|
      entity
    end
  end # class CCO::Base
end # module CCO
