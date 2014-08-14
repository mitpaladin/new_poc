
module DSO
  # Verifies that requested User attribute update is valid
  class UserUpdater < ActiveInteraction::Base
    model :user
    hash :user_data, default: {} do
      string :name, default: '', strip: true
      string :email, default: '', strip: true
      string :profile, default: 'DEFAULT', strip: true
    end

    def execute
      # First, set name/email fields if non-default values have been supplied
      update_non_profile_fields
      # Then, update the profile string unless it's set to the default string
      update_profile_field
      # Now, simple validations (but see Issue #78) and then return attributes.
      validate_user
      build_return_value
    end

    private

    def build_return_value
      {
        name:     user.name,
        email:    user.email,
        profile:  user.profile
      }
    end

    def set_item(key, value)
      user.instance_variable_set "@#{key}".to_sym, value.strip
    end

    def update_non_profile_fields
      [:name, :email].each do |attr|
        set_item(attr, user_data[attr]) if user_data[attr].present?
      end
      set_item :slug, user.name.parameterize
    end

    def update_profile_field
      return if user_data[:profile] == 'DEFAULT'

      set_item :profile, user_data[:profile]
    end

    def validate_email
      messages = ValidatesEmailFormatOf.validate_email_format user.email
      return if messages.to_a.empty?

      messages.each { |msg| errors.add :email, msg }
    end

    def validate_name
      return if user.name == user.name.to_s.split.join(' ')

      errors.add :name, 'must have only one space between words/segments'
    end

    def validate_user
      validate_name
      validate_email
    end
  end # class DSO::UserUpdater
end
