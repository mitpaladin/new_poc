
require 'spec_helper'

describe UsersController::Action::Create::PasswordLengthVerifier do
  describe 'is initalised' do
    it 'successfully with any Hash-like data' do
      expect { described_class.new some: :value }.not_to raise_error
      expect { described_class.new FancyOpenStruct.new }.not_to raise_error
    end
  end # describe 'is initialised'

  describe 'has a #verify method that' do
    desc = 'succeeds when initial attribute hash has :password that is'
    it desc do
      data = { password: 'password' }
      expect { described_class.new(data).verify }.not_to raise_error
    end

    describe 'raises an error when' do
      after :each do
        expect { described_class.new(@data).verify }.to raise_error do |e|
          payload = YAML.load e.message
          expect(payload).to be_a Hash
          expect(payload[:messages].count).to eq 1
          expected = 'Password must be longer than 7 characters'
          expect(payload[:messages].first).to eq expected
          expect(payload[:attributes]).to eq @data
        end
      end

      it 'the password is missing' do
        @data = { bogus: 'value' }
      end

      it 'the password is too short' do
        @data = { password: 'oops' }
      end

      it 'the password is too short once padding is removed' do
        @data = { password: '  oops   ' }
      end
    end # describe 'raises an error when'
  end # describe 'has a #verify method that'
end # describe UsersController::Action::Create::Passwordverifyer
