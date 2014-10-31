
require 'email_validator'
require 'name_validator'
require 'password_validator'

# Validate user data, e.g., from create-user form input. Includes passwords.
class UserDataValidator
  def initialize(user_data = {})
    @validators = []
    @validators << UserDataValidation::EmailValidator.new(user_data[:email])
    @validators << UserDataValidation::NameValidator.new(user_data[:name])
    validator_params = [user_data[:password], user_data[:password_confirmation]]
    @validators << UserDataValidation::PasswordValidator.new(*validator_params)
  end

  def valid?
    @validators.select { |validator| !validator.valid? }.empty?
  end

  def errors
    @validators.map(&:errors).flatten
  end
end # class UserDataValidator
