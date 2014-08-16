# == Schema Information
#
# Table name: user_data
#
#  id              :integer          not null, primary key
#  name            :string(255)      not null
#  email           :string(255)      not null
#  profile         :text
#  created_at      :datetime
#  updated_at      :datetime
#  password_digest :string(255)
#  slug            :string(255)
#

require 'spec_helper'

describe UserData do

  describe 'validates' do

    describe :name do

      it 'as unique' do
        user1 = FactoryGirl.build :user_datum, name: 'Joe'
        expect(user1).to be_valid
        user1.save!
        user2 = FactoryGirl.build :user_datum, name: 'Joe'
        expect(user2).to_not be_valid
      end

      it 'as present' do
        names = ['', '  ', "\t \r", nil]
        names.each do |name|
          user = FactoryGirl.build :user_datum, name: name
          expect(user).to_not be_valid
        end
      end

      describe 'as conforming to the format for' do

        describe 'invalid names' do
          after :each do
            user = FactoryGirl.build :user_datum, name: @name
            expect(user).to_not be_valid
          end

          it 'no leading whitespace' do
            @name = ' Joe'
          end

          it 'no trailing whitespace' do
            @name = 'Joe '
          end

          it 'length' do
            @name = 'Jo'
          end

          it 'adjacent internal whitespace' do
            @name = 'Joe  Blow'
          end
        end # describe 'invalid names'

        it 'valid names' do
          user = FactoryGirl.build :user_datum, name: 'Joe Blow'
          expect(user).to be_valid
        end
      end # describe 'as conforming to the format for'
    end # describe :name

    describe :slug do

      context 'with a valid name' do
        let(:user) { FactoryGirl.create :user_datum }

        it 'matches the parameterised name' do
          expect(user.slug).to eq user.name.parameterize
        end
      end # context 'with a valid name'

      # An invalid name violates a database-level constraint; no longer needed.

      # Two users cannot have the same name, or therefore the same slug.
    end # describe :slug

    describe :email do
      let(:user) { FactoryGirl.build :user_datum }

      context 'for a valid email address' do

        it 'as valid' do
          user.email = 'user@example.com'
          expect(user).to be_valid
        end
      end # context 'for a valid email address' do

      context 'for an invalid email address' do

        it 'as valid' do
          user.email = 'user at example dot com'
          expect(user).to_not be_valid
        end
      end # context 'for an invalid email address' do
    end

  end # describe 'validates'

  describe :registered do

    context 'with no registered users' do

      it 'returns an empty array' do
        expect(UserData.registered).to be_empty
        expect(UserData.all).to have(1).record
      end
    end # context 'with no registered users'

    context 'with one registered user' do
      let!(:user1) { FactoryGirl.create :user_datum }

      it 'returns an array with the one user' do
        expect(UserData.registered).to have(1).record
        expect(UserData.registered.first).to eq user1
      end
    end # context 'with one registered user'

    context 'with multiple registered users' do
      let!(:created_users) do
        ret = []
        5.times do
          ret << FactoryGirl.create(:user_datum)
        end
        ret
      end

      it 'returns an array with each of the users' do
        users = UserData.registered
        expect(users).to have(created_users.count).records
        created_users.each_with_index do |user, index|
          expect(users[index]).to eq user
        end
      end
    end # context 'with multiple registered users'
  end # describe :registered
end
