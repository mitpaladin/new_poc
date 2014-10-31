
require 'name_validator'
require 'password_validator'

# Validate user data, e.g., from create-user form input. Includes passwords.
class UserDataValidator
  def initialize(user_data = {})
    @name_validator = UserDataValidation::NameValidator.new user_data[:name]
    validator_params = [user_data[:password], user_data[:password_confirmation]]
    @password_validator = UserDataValidation::PasswordValidator
        .new(*validator_params)
  end

  def valid?
    @name_validator.valid? && @password_validator.valid?
  end

  def errors
    [
      @name_validator.errors,
      @password_validator.errors
    ].flatten
  end
end # class UserDataValidator
