
require 'spec_helper'

require 'permissive_user_creator'

# Domain-service objects should live in a module within Blog.
module DSO
  describe PermissiveUserCreator do
    let(:klass) { PermissiveUserCreator }
    let(:user_data) do
      {
        name:       'J Random User',
        email:      'jruser@example.com',
        profile:    'Just another random user',
        password:   'password',
        password_confirmation: 'password'
      }
    end

    describe 'succeeds when called with valid parameters, so that it' do

      it 'creates a valid new UserData instance' do
        instance = nil
        expect { instance = klass.run! user_data: user_data }.to_not raise_error
        expect(instance).to be_a UserData
        expect(instance).to be_valid
      end
    end # describe 'succeeds when called with valid parameters, so that it'

    describe 'succeeds when called with invalid parameters, but' do

      it 'creates an invalid new UserData instance' do
        instance = nil
        user_data[:password] = 'some invalid password junque'
        expect { instance = klass.run! user_data: user_data }.to_not raise_error
        expect(instance).to be_a UserData
        expect(instance).to_not be_valid
      end
    end # describe 'succeeds when called with invalid parameters, but'
  end # describe DSO::PermissiveUserCreator
end # module DSO
