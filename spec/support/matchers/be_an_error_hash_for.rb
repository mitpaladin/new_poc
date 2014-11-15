
RSpec::Matchers.define :be_an_error_hash_for do |field, message|

  match do |actual|
    @reasons = []
    @reasons << 'Actual must be a Hash' unless actual.is_a?(Hash)
    if actual.count != 2
      msg = "Actual must have 2 key/value pairs; found #{actual.count}"
      @reasons << msg
    end
    if actual[:field].to_s != field.to_s
      msg = "Actual must have a :field key with value '#{field}'; found " \
          "'#{actual[:field]}'"
      @reasons << msg
    end
    if actual[:message] != message.to_s
      msg = "Actual must have a :message key with value '#{message}'; found " \
      "'#{actual[:message]}'"
      @reasons << msg
    end
    @reasons.empty?
  end

  description do
    %(be an error-reporting field/message pair as returned by ) +
      %(`ErrorFactory.create')
  end

  failure_message do
    ['Expected a Hash to', description, 'but:', @reasons.join('; ')].join ' '
  end
end
