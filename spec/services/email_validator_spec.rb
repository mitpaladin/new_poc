
require 'spec_helper'

require 'email_validator'

# Validates email address, per current rules e.g., from create-user form input.
module UserDataValidation
  describe EmailValidator do
    let(:klass) { EmailValidator }
    let(:validator) { klass.new email_address }

    context 'for a valid email address, it' do
      let(:email_address) { 'joe.blow@example.com' }

      describe 'reports the address as valid by' do

        it 'returning true from #valid?' do
          expect(validator).to be_valid
        end

        it 'reports no errors' do
          expect(validator).to have(0).errors
        end
      end # describe 'reports the address as valid by'
    end # context 'for a valid email address, it' do

    context 'for an invalid email address, it' do
      let(:email_address) { 'joe blow at example dot com' }

      describe 'reports the address as invalid by' do

        it 'returning false from #valid?' do
          expect(validator).not_to be_valid
        end

        it 'reports an error' do
          expect(validator).to have(1).error
        end

        it 'reports the expected error message' do
          message = 'does not appear to be a valid e-mail address'
          expected = { email: message }
          expect(validator.errors.first).to eq expected
        end
      end # describe 'reports the address as invalid by'
    end # context 'for an invalid email address, it'
  end # describe UserDataValidation::EmailValidator
end # module UserDataValidation
