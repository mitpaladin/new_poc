
# Class used to set instance variables on other classes.
#
# Example:
#
# class Foo
#   attr_reader :foo, :bar, :baz, :quux
#   def initialize(attrs = {})
#     InstanceVariableSetter.new(self).set attrs
#   end
#   # ...
#   private
#   # ...
#   def init_attrib_keys
#     [:foo, :bar] # or %w(foo bar)
#   end
# end
#
# Alternate example class and usage
#
# class Foo
#   attr_reader :foo, :bar, :baz, :quux
#   def initialize(attrs = {})
#     InstanceVariableSetter.new(self) do
#       allow_attributes %w(foo bar)
#       # or: allow_attributes [:foo, :bar]
#     end.set(attrs)
#   end
#   # ...
# end
# ...
#
# Note that mixing the two styles is not supported.
#
# Instantiation of client class (in either case)
# the_foo = Foo.new foo: 'hello', bar: 21, baz: 'nothing here'
# puts the_foo.foo
# # "hello"
# puts the_foo.baz
# # nil
#
# This is useful, for instance, when passing in ActiveModel instances to #set;
# API-related fields that aren't the entity-value fields we've said we want are
# ignored.
class InstanceVariableSetter
  def initialize(dest_obj, &block)
    @dest_obj = dest_obj
    @allowed_attributes = initial_allowed_attributes
    instance_eval(&block) if block_given?
  end

  def allow_attributes(attribs)
    @allowed_attributes = attribs.map(&:to_sym)
  end

  def set(attribs)
    allowed_attributes.each { |attrib_sym| set_ivar_for attrib_sym, attribs }
    self
  end

  private

  attr_reader :allowed_attributes, :dest_obj

  def initial_allowed_attributes
    return [] unless dest_obj.respond_to?(:init_attrib_keys, true)
    dest_obj.send(:init_attrib_keys).map(&:to_sym)
  end

  def ivar_for(sym)
    "@#{sym}".to_sym
  end

  def set_ivar_for(key, attribs)
    value = attribs[key] || attribs[key.to_s]
    return if value.nil?
    dest_obj.instance_variable_set ivar_for(key), value
    self
  end
end
