
require 'spec_helper'

describe UserDao do

  describe 'validates' do

    describe :name do

      it 'as unique' do
        build_user = -> { FactoryGirl.build :user, :new_user, name: 'Joe' }
        user1 = build_user.call
        expect(user1).to be_valid
        user1.save!
        user2 = build_user.call
        expect(user2).to_not be_valid
      end

      it 'as present' do
        build_user = ->(name) { FactoryGirl.build :user, :new_user, name: name }
        names = ['', '  ', "\t \r", nil]
        names.each do |name|
          user = build_user.call name
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
          user = FactoryGirl.build :user, :new_user, name: 'Joe Blow'
          expect(user).to be_valid
        end
      end # describe 'as conforming to the format for'
    end # describe :name

    describe :slug do

      context 'with a valid name' do
        let(:user) { FactoryGirl.build(:user).tap(&:save!) }

        it 'matches the parameterised name' do
          expect(user.slug).to eq user.name.parameterize
        end
      end # context 'with a valid name'
    end # describe :slug

    describe :email do
      let(:user) { FactoryGirl.build :user }

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
    end # describe :email
  end # describe 'validates'
end # describe User
