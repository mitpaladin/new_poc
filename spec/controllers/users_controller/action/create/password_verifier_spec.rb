
require 'spec_helper'

describe UsersController::Action::Create::PasswordVerifier do
  describe 'is initalised' do
    it 'successfully with any Hash-like data' do
      expect { described_class.new some: :value }.not_to raise_error
      expect { described_class.new FancyOpenStruct.new }.not_to raise_error
    end
  end # describe 'is initialised'

  describe 'has a #verify method that' do
    desc = 'succeeds when initial attribute hash has matching :password and' \
      ' :password_confirmation values'
    it desc do
      data = { password: 'password', password_confirmation: 'password' }
      expect { described_class.new(data).verify }.not_to raise_error
    end

    describe 'raises an error when' do
      it 'the passwords do not match' do
        data = { password: 'password', password_confirmation: 'other password' }
        expect { described_class.new(data).verify }.to raise_error do |e|
          match1 = /Password must match the password confirmation/
          expect(e.message).to match match1
          expect(e.message).to match(/password: password/)
          expect(e.message).to match(/password_confirmation: other password/)
        end
      end

      it 'no passwords are specified' do
        data = { foo: 'bar', meaning: 42 }
        expect { described_class.new(data).verify }.to raise_error
      end
    end # describe 'raises an error when'
  end # describe 'has a #verify method that'
end # describe UsersController::Action::Create::PasswordVerifier
