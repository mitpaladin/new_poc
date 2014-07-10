
require 'spec_helper'

describe User do
  let(:default_attribs) { FactoryGirl.attributes_for :user_datum }

  describe 'is a value object with attributes for' do
    let(:user) { User.new default_attribs }

    after :each do
      getter = RSpec.current_example.description.to_sym
      expect(user.send getter).to eq default_attribs[getter]
      setter = [getter.to_s, '='].join.to_sym
      expect { user.send setter, 'Fudd' }.to raise_error NoMethodError
    end

    it :name do
    end

    it :email do
    end

    it :profile do
    end

    it :session_token do
    end
  end # describe 'is a value object with attributes for'

  describe :registered? do

    context 'for the guest user' do
      let(:user) do
        own_attribs = { name: User.guest_user_name }
        User.new default_attribs.merge(own_attribs)
      end

      it 'returns false' do
        expect(user).to_not be_registered
      end
    end # context 'for the guest user'

    context 'for a registered user' do
      let(:user) { User.new default_attribs }

      it 'returns true' do
        expect(user).to be_registered
      end
    end # context 'for a registered user'
  end # describe :registered?
end
