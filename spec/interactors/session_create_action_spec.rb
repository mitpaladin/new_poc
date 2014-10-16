
require 'spec_helper'

require 'session_create_action'
require_relative 'shared_examples/a_successful_storeresult'
require_relative 'shared_examples/an_unsuccessful_storeresult_with'

shared_examples 'an invalid session context' do |description, name, password|
  context description do
    let!(:user) { FactoryGirl.create :user, :saved_user }
    let(:params) do
      ret = Struct.new(:user, :password).new
      ret.user = name == :ignore ? user.name : name
      ret.password = password == :ignore ? user.password : password
      ret
    end

    describe 'it returns a StoreResult with' do
      let(:result) { klass.run! params: params.to_h }

      it_behaves_like 'an unsuccessful StoreResult with', :base,
                      'Invalid user name or password'
    end # describe 'it returns a StoreResult with'
  end # context
end # shared_examples do 'an invalid session context'

# Module DSO2 contains our second-generation Domain Service Objects, aka
#   "interactors".
module DSO2
  describe SessionCreateAction, outer: true do
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

          it_behaves_like 'a successful StoreResult'

          it 'an "entity" field with correct attributes' do
            dao = UserDao.find_by_slug user.name.parameterize
            entity_attributes.each do |attr|
              expect(result.entity.send attr).to eq dao[attr]
            end
          end
        end # describe 'it returns a StoreResult with'
      end # context 'a valid user name and password'

      # Invalid validation/session creation contexts.

      it_behaves_like 'an invalid session context',
                      'a valid user name and invalid password',
                      :ignore, 'Bogus Password'

      it_behaves_like 'an invalid session context',
                      'an invalid user name',
                      'nobody here', :ignore
    end # describe 'with input params containing'
  end # describe SessionCreateAction
end # module DSO2
