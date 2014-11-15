
# Support classes for UserDataValidator.
module UserDataValidation
  # Validates email address, per current rules e.g. from create-user form input.
  class EmailValidator
    def initialize(email)
      @errors = []
      @email = email.to_s
    end

    def errors
      valid?  # ensure that validation is performed
      @errors.flatten.map { |message| { email: message } }
    end

    def valid?
      email_has_valid_format?
    end

    private

    attr_reader :email

    def add_error(message)
      # protect against redundant adding of error messages
      # (e.g. #errors following #valid?)
      return @errors if @errors.include? message
      @errors << message
    end

    def email_has_valid_format?
      message = ValidatesEmailFormatOf.validate_email_format email
      add_error(message) unless message.nil?
      message.nil?
    end
  end # class UserDataValidation::EmailValidator
end # module UserDataValidation
