
RSpec::Matchers.define :be_same_timestamped_entity_as do |source|
  match do |actual|
    @verifier = TimestampedEntityVerifier.new source, actual
    @verifier.verify.failures.empty?
  end

  description do
    'two entities to have the same domain-entity fields, including' \
      ' timestamps. Implementation-only fields like passwords for User' \
      ' entities are NOT "domain-entity fields".'
  end

  failure_message do
    "Expected #{description} Comparison of the following fields failed: " +
      @verifier.failures.join('; ')
  end
end # RSpec::Matchers.define :be_same_timeless_entity_as
