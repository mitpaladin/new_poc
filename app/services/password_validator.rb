
# Support classes for UserDataValidator.
module UserDataValidation
  # Validates user password, per current rules eg, from create-user form input.
  class PasswordValidator
    def initialize(password, password_confirmation)
      @errors = []
      @password = password.to_s
      @password_confirmation = password_confirmation.to_s
    end

    def errors
      valid?  # ensure that validation is performed
      @errors.flatten.map { |message| { password: message } }
    end

    def valid?
      password_and_confirmation_match? &&
          !password_has_whitespace_at_ends? &&
          password_is_long_enough?
    end

    private

    attr_reader :password, :password_confirmation

    def add_error(message)
      # protect against redundant adding of error messages
      # (e.g. #errors following #valid?)
      return @errors if @errors.include? message
      @errors << message
    end

    def password_and_confirmation_match?
      (password == password_confirmation).tap do |matching|
        add_error('and password confirmation do not match') unless matching
      end
    end

    def password_has_whitespace_at_ends?
      (password != password.strip).tap do |ret|
        add_error('may not contain leading or trailing whitespace') if ret
      end
    end

    def password_is_long_enough?
      (password.length >= 8).tap do |long_enough|
        add_error('is not long enough') unless long_enough
      end
    end
  end # class UserDataValidation::PasswordValidator
end # module UserDataValidation
