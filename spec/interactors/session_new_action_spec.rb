
require 'spec_helper'

require 'session_new_action'

# module DSO2
describe SessionNewAction do
  let(:klass) { SessionNewAction }

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

  context 'with valid input params containing a user name and pasword' do
    let(:user) { FactoryGirl.create :user, :saved_user }
    let(:params) { { user: user.name, password: user.password } }

    describe 'it returns a StoreResult with' do
      let(:result) { SessionNewAction.run! params: params }
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
  end # context 'with valid input params containing a user name and pasword'
end # describe SessionNewAction
# end # module DSO2
