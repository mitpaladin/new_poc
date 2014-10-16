
require 'spec_helper'

require 'session_create_action'

# Module DSO2 contains our second-generation Domain Service Objects, aka
#   "interactors".
module DSO2
  describe SessionCreateAction do
    let(:klass) { SessionCreateAction }

    describe 'requires a :params hash' do
      describe 'and raises an error when called' do
        let(:error_class) { ActiveInteraction::InvalidInteractionError }

        it 'without parameters' do
          expect { klass.run! }.to raise_error error_class, 'Params is required'
        end

        it 'with an empty "params" hash' do
          message = 'Params has an invalid nested value ("user" => nil)'
          expect { klass.run! params: {} }.to raise_error error_class, message
        end

        it 'with a :user param but without a password' do
          message = 'Params has an invalid nested value ("password" => nil)'
          expect { klass.run! params: { user: 'duck' } }
              .to raise_error error_class, message
        end
      end # describe 'and raises an error when called'
    end # describe 'requires a :params hash'

    describe 'with input params containing' do
      let!(:user) { FactoryGirl.create :user, :saved_user }
      context 'a valid user name and password' do
        let(:params) { { user: user.name, password: user.password } }

        describe 'it returns a StoreResult with' do
          let(:result) { klass.run! params: params }
          let(:entity_attributes) do
            [:created_at, :email, :name, :profile, :slug, :updated_at]
          end

          it 'a truthy "success" field' do
            expect(result).to be_success
          end

          it 'an empty "errors" field' do
            expect(result.errors).to be_empty
          end

          it 'an "entity" field with correct attributes' do
            dao = UserDao.find_by_slug user.name.parameterize
            entity_attributes.each do |attr|
              expect(result.entity.send attr).to eq dao[attr]
            end
          end
        end # describe 'it returns a StoreResult with'
      end # context 'a valid user name and password'

      context 'a valid user name and invalid password' do
        let(:params) { { user: user.name, password: 'Bogus Password' } }

        describe 'it returns a StoreResult with' do
          let(:result) { klass.run! params: params }

          it 'a falsy "success" field' do
            expect(result).not_to be_success
          end

          it 'an "invalid user name or password" error message' do
            expect(result).to have(1).error
            error = result.errors.first
            expect(error[:field]).to eq 'base'
            expect(error[:message]).to eq 'Invalid user name or password'
          end
        end # describe 'it returns a StoreResult with'
      end # context 'a valid user name and invalid password'

      fcontext 'an invalid user name' do
        let(:params) { { user: 'nobody here', password: 'Bogus Password' } }

        describe 'it returns a StoreResult with' do
          let(:result) { klass.run! params: params }

          it 'a falsy "success" field' do
            expect(result).not_to be_success
          end

          it 'an "invalid user name or password" error message' do
            expect(result).to have(1).error
            error = result.errors.first
            expect(error[:field]).to eq 'base'
            expect(error[:message]).to eq 'Invalid user name or password'
          end
        end # describe 'it returns a StoreResult with'
      end # context 'an invalid user name'
    end # describe 'with input params containing'
  end # describe SessionCreateAction
end # module DSO2
