
require 'spec_helper'

require 'user_updater'

# Module DSO contains our Domain Service Objects, aka "interactors".
module DSO
  describe UserUpdater do
    let(:original_attribs) { FactoryGirl.attributes_for :user_datum }
    let(:user) { User.new original_attribs }
    let(:name) { 'Thurston Howell, III' }
    let(:email) { 'thurston@example.com' }
    let(:profile) { 'A *very* wealthy SOB' }
    let(:user_data) { { name: name, email: email, profile: profile } }

    describe 'succeeds when called with' do

      it 'a complete set of valid attributes' do
        result = UserUpdater.run user: user, user_data: user_data
        expect(result.errors).to be_empty
      end

      describe 'a partial set of valid attributes, including' do
        after :each do
          result = UserUpdater.run user: user, user_data: @data
          expect(result.errors).to be_empty
        end

        describe 'the single attribute' do
          [:name, :email, :profile].each do |attr|

            it ":#{attr}" do
              @data = {}
              @data[attr] = user_data[attr]
            end
          end
        end # describe 'the single attribute'

        describe 'all valid attributes EXCEPT for' do
          [:name, :email, :profile].each do |excluded|

            it ":#{excluded}" do
              @data = user_data.clone
              @data.delete excluded
            end
          end
        end # describe 'all valid attributes EXCEPT for'
      end # describe 'a partial set of valid attributes, including'
    end # describe 'succeeds when called with'

    describe 'fails when called with' do
      after :each do
        result = UserUpdater.run user: user, user_data: @data
        expect(result.errors.full_messages).to eq @expected
      end

      it 'an invalid email address' do
        @data = user_data.clone.merge email: 'bogus email address'
        @expected = ['Email does not appear to be a valid e-mail address']
      end

      # A reminder: the DSO strips leading/trailing spaces from hash items.
      # This is relevant because the UserData class specifically marks such a
      # name field as invalid. Passing such a string in here will produce a
      # valid name. Whether that's what the user intended...is another question.
      it 'a user name with multiple adjacent embedded spaces' do
        @data = user_data.clone.merge name: 'Joe   Blow'
        @expected = ['Name must have only one space between words/segments']
      end
    end # describe 'fails when called with'

    describe 'when successfully called, returns the updated attributes for' do
      after :each do
        result = UserUpdater.run user: user, user_data: @new_data
        expect(result.result).to eq @expected
      end

      it 'a single attribute' do
        @new_data = { name: user_data[:name] }
        @expected = {
          name:     @new_data[:name],
          email:    original_attribs[:email],
          profile:  original_attribs[:profile]
        }
      end

      it 'two attributes' do
        @new_data = { name: user_data[:name], email: user_data[:email] }
        @expected = {
          name:     @new_data[:name],
          email:    @new_data[:email],
          profile:  original_attribs[:profile]
        }
      end

      it 'name, email and profile' do
        @new_data = user_data.clone
        @expected = user_data
      end
    end # describe 'when successfully called, returns the updated attributes...'
  end # describe UserUpdater
end # module DSO
