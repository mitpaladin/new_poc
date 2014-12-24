
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
# Previous instantiation example *that justified the existence of the class*.
# This usage is NO LONGER SUPPORTED.
#
# class Foo
#   attr_reader :foo, :bar
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
# Instantiation of client class (in either case)
# the_foo = Foo.new foo: 'hello', bar: 21, baz: 'nothing here'
# puts the_foo.foo
# # "hello"
# puts the_foo.baz
# # nil
# puts the_foo.instance_variables
# [:foo, :bar]
# (Note the omission of :baz, specified in the initialiser call.)
class InstanceVariableSetter
  def initialize(dest_obj)
    @dest_obj = dest_obj
    @allowed_attributes = initial_allowed_attributes
  end

  def set(attribs)
    allowed_attributes.each { |attrib_sym| set_ivar_for attrib_sym, attribs }
    self
  end

  private

  attr_reader :allowed_attributes, :dest_obj

  def initial_allowed_attributes
    return [] unless dest_obj.respond_to? :init_attrib_keys, true
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
