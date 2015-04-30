
RSpec::Matchers.define :violate_a_param_contract do
  define_method :is_expected_violation? do
    result = true
    result &&= @data[:arg] == @arg if @arg
    result &&= @data[:contract].name == @identified_by.name if @identified_by
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
