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
end
