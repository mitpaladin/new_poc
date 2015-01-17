require 'spec_helper'

describe Newpoc::Entity::User do
  let(:valid_subset) do
    {
      name: 'Joe Blow',
      email: 'joe@example.com',
      password: 'password',
      password_confirmation: 'password_confirmation'
    }
  end

  it 'has a version number' do
    expect(Newpoc::Entity::User::VERSION).not_to be nil
  end

  describe 'supports initialisation' do
    describe 'succeeding' do
      it 'with the minimum set of valid field names' do
        expect { described_class.new valid_subset }.not_to raise_error
      end
    end # describe 'succeeding'
  end # describe 'supports initialisation'
end # describe Newpoc::Entity::User
