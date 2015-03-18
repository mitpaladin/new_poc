
require 'spec_helper'

describe UserPasswordEntityFactory do
  describe 'has a .create class method that' do
    describe 'returns an object with' do
      let(:password) { 'password' }
      let(:user_email) { 'some.user@example.com' }
      let(:user_name) { 'Some User' }
      let(:valid_attributes) { { name: user_name, email: user_email } }

      it 'has .password and .password_confirmation attribute writers' do
        obj = described_class.create valid_attributes, 'anything'
        expect { obj.password = 'password' }.not_to raise_error
        expect { obj.password_confirmation = 'password' }.not_to raise_error
      end

      context 'when called with a second parameter, returns' do
        let(:obj) { described_class.create valid_attributes, password }

        it 'the parameter value as the password attribute' do
          expect(obj.password).to eq password
        end

        it 'the parameter value as the password_confirmation attribute' do
          expect(obj.password_confirmation).to eq password
        end

        it 'true from the #valid? method' do
          expect(obj).to be_valid
        end
      end # context 'when called with a second parameter, returns'

      context 'when called with a single parameter with otherwise valid data' do
        context 'with no password values specified, returns' do
          let(:obj) { described_class.create valid_attributes }

          it 'true from the #valid? method (not specified in update)' do
            expect(obj).to be_valid
          end

          it 'nil for the #password attribute' do
            expect(obj.password).to be nil
          end

          it 'nil for the #password_confirmation attribute' do
            expect(obj.password_confirmation).to be nil
          end
        end # context 'with no password values specified, returns'

        context 'with the same password/confirmation specified, returns' do
          let(:attributes) do
            { password: password,
              password_confirmation: password }.merge valid_attributes
          end
          let(:obj) { described_class.create attributes }

          it 'true from the #valid? method' do
            expect(obj).to be_valid
          end

          it 'the specified password as the #password attribute' do
            expect(obj.password).to eq password
          end

          it 'the specified password as the #password_confirmation attribute' do
            expect(obj.password_confirmation).to eq password
          end
        end # context 'with the same password/confirmation specified, returns'

        context 'with different password and confirmation specified, returns' do
          let(:attributes) do
            { password: 'non-matching password',
              password_confirmation: password }.merge valid_attributes
          end
          let(:obj) { described_class.create attributes }

          fit 'false from the #valid? method' do
            ap [{ File.basename(__FILE__) => __LINE__ },
                'the next two should be the same in order to be valid',
                obj.password, obj.password_confirmation,
                '#valid? returns',
                obj.valid?]
            expect(obj).not_to be_valid
          end
        end # context 'with different password and confirmation specified, ...'
      end # context 'when called with a single parameter with ... valid data'
    end # describe 'returns an object with'
  end # describe 'has a .create class method that'
end # describe UserPasswordEntityFactory
