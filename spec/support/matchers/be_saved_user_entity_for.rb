
RSpec::Matchers.define :be_saved_user_entity_for do |source|

  match do |actual|
    @reasons = SavedEntityVerifier.new(source, actual) do
      required_in_source :password, :password_confirmation
      required_in_actual :created_at, :updated_at
      required_in_both :name, :email, :profile
      verify
    end.reasons
    @reasons.empty?
  end

  description do
    [%(have the same name, email and profile fields, with only the source),
     %(having password and password-confirmation fields and only the target),
     %(having created-on and updated-on timestamps)].join ' '
  end

  failure_message do
    %(Expected a source and target(post-save) entity to #{description}, but ) +
      @reasons.join('; and ')
  end
end # RSpec::Matchers.define :be_saved_user_entity_for
