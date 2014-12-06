
# Generic "summarise" class without specific domain knowledge.
class BaseSummariser
  attr_writer :count

  def initialize(&block)
    @count = 10
    @data_class ||= 'UNKNOWN DATA CLASS; SOME CLASS SHOULD BE ASSIGNED HERE'
    @aggregator ||= default_aggregator
    @chunker ||= -> (data) { data.take @count }
    @selector ||= dsl_passthrough
    @sorter ||= dsl_passthrough
    @orderer ||= dsl_passthrough
    instance_eval(&block) if block
  end

  def summarise_data(data)
    summary_steps.each do |op|
      step = instance_variable_get('@' + op.to_s)
      data = step.call data
    end
    data
  end

  def method_missing(name, *args, &block)
    return super unless dsl_name? name
    instance_variable_set "@#{name}".to_sym, *args
  end

  def respond_to?(method, include_private = false)
    super || dsl_name?(method)
  end

  private

  def default_aggregator
    -> { @data_class.all }
  end

  def dsl_name?(name)
    dsl_methods.include? name
  end

  def dsl_methods
    [:aggregator, :selector, :sorter, :orderer, :chunker]
  end

  def dsl_passthrough
    -> (data) { data }
  end

  def summary_steps
    dsl_methods.drop(1)
  end
end # class BaseSummariser
