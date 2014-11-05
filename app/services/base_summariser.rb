
# Generic "summarise" class without specific domain knowledge.
class BaseSummariser
  attr_writer :count

  # rubocop:disable Metrics/AbcSize
  def initialize(&block)
    @count ||= 10
    @data_class ||= 'UNKNOWN DATA CLASS; SOME CLASS SHOULD BE ASSIGNED HERE'
    @aggregator ||= -> { @data_class.all }
    @selector ||= -> (data) { data }
    @sorter ||= -> (data) { data }
    @orderer ||= -> (data) { data }
    @chunker ||= -> (data) { data.take @count }
    instance_eval(&block) if block
  end
  # rubocop:enable Metrics/AbcSize

  # The initial value of `data` was originally supplied via an :aggregator step
  # (with matching DSL method). Removing that and supplying the initial data
  # explicitly *significantly* simplifies the logic, particularly when dealing
  # with Rails 4.1+.
  def summarise_data(data)
    summary_steps.each do |op|
      step = ('@' + op.to_s).to_sym
      data = instance_variable_get(step).call data
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

  def dsl_name?(name)
    dsl_methods.include? name
  end

  def dsl_methods
    [:aggregator, :selector, :sorter, :orderer, :chunker]
  end

  def summary_steps
    dsl_methods.drop(1)
  end
end # class BaseSummariser
