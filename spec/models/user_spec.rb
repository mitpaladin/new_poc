
require 'spec_helper'

shared_examples 'a flag set based on user state' do |attr_sym, for_guest|
  # Defaults
  for_guest = false if for_guest.nil?
  for_user = !for_guest

  # Memoised fixtures
  let(:default_attribs) do
    own_attribs = { session_token: SecureRandom.urlsafe_base64 }
    FactoryGirl.attributes_for(:user_datum).merge own_attribs
  end
  let(:guest_attribs) do
    own_attribs = { name: User.guest_user_name, session_token: nil }
    default_attribs.merge(own_attribs)
  end

  describe attr_sym do

    context 'for the guest user' do
      let(:user) { User.new guest_attribs }

      it "returns #{for_guest}" do
        expect(user.send attr_sym).to be for_guest
      end
    end # context 'for the guest user'

    context 'for a registered user' do
      let(:user) { User.new default_attribs }

      it "returns #{for_user}" do
        expect(user.send attr_sym).to be for_user
      end
    end # context 'for a registered user'
  end # describe attr_sym
end # shared_examples 'a flag set based on user state'

shared_examples 'a value object with read-only attribute' do |getter_sym|
  it getter_sym do
    own_attribs = { session_token: SecureRandom.urlsafe_base64 }
    default_attribs = FactoryGirl.attributes_for(:user_datum).merge own_attribs
    user = User.new default_attribs
    expect(user.send getter_sym).to eq default_attribs[getter_sym]
    setter = [getter_sym.to_s, '='].join.to_sym
    expect { user.send setter, 'Fudd' }.to raise_error NoMethodError
  end
end # shared_examples 'a value object with read-only attribute'

# ############################################################################ #
# ############################################################################ #
# ############################################################################ #

describe User do
  it_behaves_like 'a value object with read-only attribute', :name

  it_behaves_like 'a value object with read-only attribute', :email

  it_behaves_like 'a value object with read-only attribute', :profile

  it_behaves_like 'a value object with read-only attribute', :slug

  it_behaves_like 'a flag set based on user state', :authenticated?

  it_behaves_like 'a flag set based on user state', :registered?
end
