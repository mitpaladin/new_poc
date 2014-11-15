
require 'spec_helper'

require 'password_validator'

shared_examples 'an invalid password' do |description, password_in, confirm_in,
      message|
  context description do
    let(:password) { password_in }
    let(:password_confirmation) { confirm_in }

    it 'is not valid' do
      expect(validator).not_to be_valid
    end

    it 'has one error' do
      expect(validator).to have(1).error
    end

    it 'has the correct error message' do
      expected = { password: message }
      expect(validator.errors.first).to eq expected
    end
  end # context description
end # shared_examples 'aan invalid name'

# Support classes for UserDataValidator.
module UserDataValidation
  describe PasswordValidator do
    let(:klass) { PasswordValidator }
    let(:validator) { klass.new password, password_confirmation }

    context 'for a valid password' do
      let(:password) { 'password' }   # not good, but valid :-P
      let(:password_confirmation) { password }

      it 'is valid' do
        expect(validator).to be_valid
      end

      it 'has no errors' do
        expect(validator).to have(0).errors
      end
    end # context 'for a valid name'

    context 'for a password that is invalid because' do

      it_behaves_like 'an invalid password',
                      "password and confirmation don't match",
                      'password', 'confirmation',
                      'and password confirmation do not match'

      message = 'may not contain leading or trailing whitespace'
      it_behaves_like 'an invalid password', 'it contains leading whitespace',
                      '  password', '  password', message

      it_behaves_like 'an invalid password', 'it contains trailing whitespace',
                      'password ', 'password ', message

      it_behaves_like 'an invalid password', 'it is not long enough',
                      'bogus', 'bogus', 'is not long enough'
    end # context 'for a name that is invalid because'
  end # describe UserDataValidation::PasswordValidator
end # module UserDataValidation
