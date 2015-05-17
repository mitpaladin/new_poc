
RSpec::Matchers.define :violate_a_param_contract do
  define_method :is_valid_either_or? do
    valid_values = @data[:contract].instance_variable_get :@vals
    return false unless valid_values.respond_to? :include? # i.e., if nil
    @identified_by_either_or.reject { |v| valid_values.include? v }.empty?
  end

  define_method :is_expected_violation? do
    result = true
    result &&= @data[:arg] == @arg if @arg
    result &&= @data[:contract].name == @identified_by.name if @identified_by
    result &&= is_valid_either_or? if @identified_by_either_or
    return result unless @returning
    result && @data[:contracts].ret_contract.name == @returning.name
  end

  match do |actual|
    begin
      actual.call
    rescue ParamContractError => e
      @data = e.data
      is_expected_violation?
    rescue
      false
    end
  end

  chain :identified_by_either_or, :identified_by_either_or

  chain :identified_by, :identified_by

  chain :returning, :returning

  chain :with_arg, :arg

  description do
    result = 'violate a Contract specifying method parameters'
    result += ", implemented in class #{@identified_by.name}" if @identified_by
    result += ", and with expected argument #{@arg.inspect}" if @arg
    result += ", and returning #{@returning}" if @returning
    result
  end

  failure_message do |actual|
    "expected #{actual} to #{description}"
  end

  def supports_block_expectations?
    true
  end
end # RSpec::Matchers.define :violate_a_param_contract
