
require 'contracts'

# Generic "summarise" class without specific domain knowledge.
class BaseSummariser
  include Contracts

  attr_writer :count

  Contract Maybe[Proc] => BaseSummariser
  def initialize(&block)
    @count = 10
    @data_class ||= 'UNKNOWN DATA CLASS; SOME CLASS SHOULD BE ASSIGNED HERE'
    @aggregator ||= default_aggregator
    @chunker ||= -> (data) { data.take @count }
    @selector ||= dsl_passthrough
    @sorter ||= dsl_passthrough
    @orderer ||= dsl_passthrough
    instance_eval(&block) if block
    self
  end

  # Why the completely permissive Contract? Because, by implementing your own
  # chunker, selector, sorter, etc., you can do anything you like to/with the
  # data. This class has a default chunker that assumes that `data` responds to
  # `:take`, for instance, but that's easily overrideable. Contracts of parent
  # classes (as this was designed to be) aren't so malleable.
  Contract Any => Any
  def summarise_data(data)
    summary_steps.each do |op|
      step = instance_variable_get('@' + op.to_s)
      data = step.call data
    end
    data
  end

  # Contract not defined; AFAIK Contracts doesn't support `*args`
  def method_missing(name, *args, &block)
    return super unless dsl_name? name
    instance_variable_set "@#{name}".to_sym, *args
  end

  # Adding a Contract here yields a `stack level too deep` on instantiation.
  # Contract Or[Symbol, String], Maybe[Bool] => Bool
  def respond_to?(method, include_private = false)
    super || dsl_name?(method)
  end

  private

  Contract None => Proc
  def default_aggregator
    -> { @data_class.all }
  end

  # Contracts not allowed on code called from `method_missing`.
  # Contract Any => Bool
  def dsl_name?(name)
    dsl_methods.include? name
  end

  # Contracts not allowed on code called from `method_missing`.
  # Contract None => ArrayOf[Symbol]
  def dsl_methods
    [:aggregator, :selector, :sorter, :orderer, :chunker]
  end

  Contract None => Proc
  def dsl_passthrough
    -> (data) { data }
  end

  Contract None => ArrayOf[Symbol]
  def summary_steps
    dsl_methods.drop(1)
  end
end # class BaseSummariser
