
# Class used to set instance variables on other classes.
#
# Example:
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
# the_foo = Foo.new foo: 'hello', bar: 21
# puts the_foo.foo
# # "hello"
#
# Alternate example class and usage:
#
# class Foo
#   attr_reader :foo, :bar
#   def initialize(attrs = {})
#     InstanceVariableSetter.new(self).set attrs
#   end
#   # ...
#   def init_attrib_keys
#     %w(foo bar) # or [:foo, :bar]
#   end
# end
#
class InstanceVariableSetter
  def initialize(dest_obj, &block)
    @dest_obj = dest_obj
    @allowed_attributes = initial_allowed_attributes
    instance_eval(&block) if block
  end

  def allow_attributes(attribs)
    @allowed_attributes = attribs.map(&:to_sym)
  end

  def set(attribs)
    allowed_attributes.each { |attrib_sym| set_ivar_for attrib_sym, attribs }
  end

  private

  attr_reader :allowed_attributes, :dest_obj

  def initial_allowed_attributes
    return [] unless dest_obj.respond_to? :init_attrib_keys
    dest_obj.init_attrib_keys.map(&:to_sym)
  end

  def ivar_for(sym)
    "@#{sym}".to_sym
  end

  def set_ivar_for(key, attribs)
    value = attribs[key] || attribs[key.to_s]
    return if value.nil?
    dest_obj.instance_variable_set ivar_for(key), value
  end
end
