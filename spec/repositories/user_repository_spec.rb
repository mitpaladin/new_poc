
require 'spec_helper'

require_relative 'shared_examples/the_initialize_method_for_a_repository'
require_relative 'shared_examples/the_add_method_for_a_repository'
require_relative 'shared_examples/the_all_method_for_a_repository'
require_relative 'shared_examples/the_delete_method_for_a_repository'
require_relative 'shared_examples/the_find_by_slug_method_for_a_repository'
require_relative 'shared_examples/the_update_method_for_a_repository'

shared_examples 'a result with a Guest User entity' do
  it 'is a successful result with a Guest User entity' do
    expect(result).to be_success
    expect(result).to have(0).errors
    expect(result.entity.name).to eq 'Guest User'
  end
end

describe UserRepository do
  let(:klass) { UserRepository }
  let(:be_entity_for) do
    ->(entity) { be_saved_user_entity_for(entity) }
  end
  let(:dao_class) { UserDao }
  let(:factory_class) { UserFactory }
  let(:entity_class) { UserEntity }
  let(:obj) { klass.new }
  let(:user_name) { 'Joe Blow' }
  let(:email) { 'jblow@example.com' }
  let(:password) { 'password' }
  let(:entity_attributes) do
    FactoryGirl.attributes_for :user, :saved_user
  end
  let(:entity) do
    entity_class.new entity_attributes
  end
  let(:save_error_data) { { frobulator: 'is busted' } }
  let(:record_errors) do
    e = ActiveModel::Errors.new(obj)
    e.add save_error_data.keys.first, save_error_data.values.first
    e
  end
  let(:all_list_count) { 3 }
  let(:all_attributes_list) do
    FactoryGirl.attributes_for_list :user, all_list_count, :saved_user
  end

  before :each do
    password = SecureRandom.base64
    profile = %(This is the un-authenticated Guest User for the system.)
    UserDao.create name:  'Guest User',
                   email: 'guest@example.com',
                   profile:  profile,
                   password: password,
                   password_confirmation: password
  end

  describe :initialize.to_s do
    it_behaves_like 'the #initialize method for a Repository'
  end # describe :initialize

  describe :add.to_s do
    it_behaves_like 'the #add method for a Repository'
  end # describe :add

  describe :all.to_s do
    it_behaves_like 'the #all method for a Repository'

    it 'does not return the Guest User in a call to :all' do
      find_guest_user = ->(u) { u.slug == 'guest-user' }
      expect(obj.all.select { |u| find_guest_user.call u }).to be_empty
      dao = obj.instance_variable_get :@dao
      expect(dao.all.select { |u| find_guest_user.call u }).to have(1).entry
    end
  end # describe :all

  describe :delete.to_s do
    it_behaves_like 'the #delete method for a Repository'
  end # describe :delete

  describe :find_by_name.to_s do
    context 'record not found' do

      it 'returns the expected StoreResult' do
        result = obj.find_by_name 'Nobody Home'
        expect(result).not_to be_success
        expect(result.entity).to be nil
        expect(result).to have(1).error
        expected_message = "A record with 'name'=Nobody Home was not found."
        expect(result.errors.first)
            .to be_an_error_hash_for :base, expected_message
      end
    end # context 'record not found'

    context 'record exists' do
      let(:result) do
        obj.add entity
        obj.find_by_name entity.name
      end

      it 'returns the expected StoreResult' do
        expect(result).to be_success
        expect(result.errors).to be nil
        expect(result.entity).to be_a entity_class
        expect(result.entity).to be_entity_for.call(entity)
      end
    end # context 'record exists'
  end # describe :find_by_name

  describe :find_by_slug.to_s do
    it_behaves_like 'the #find_by_slug method for a Repository'
  end # describe :find_by_slug

  describe :update.to_s do
    let(:attribute_to_update) { :profile }
    let(:updated_attribute) { '*Updated* meaningless profile.' }

    it_behaves_like 'the #update method for a Repository'
  end # describe :update'

  describe :authenticate.to_s do
    context 'for an existing user' do
      let(:dao) { FactoryGirl.create :user, :saved_user }
      let(:user) { dao.name }

      context 'with a correct password' do
        let(:password) { dao.password }

        describe 'it returns a StoreResult with' do
          let(:result) { obj.authenticate user, password }
          let(:entity_attributes) do
            [:created_at, :email, :name, :profile, :slug, :updated_at]
          end

          it 'the "success" field set to true' do
            expect(result).to be_success
          end

          it 'an empty "errors" field' do
            expect(result.errors).to be_empty
          end

          it 'an "entity" field with the correct attributes' do
            entity_attributes.each do |attr|
              expect(result.entity.send attr).to eq dao[attr]
            end
          end
        end # describe 'it returns a StoreResult with'
      end # context 'with a correct password'
    end # context 'for an existing user'
  end # describe :authenticate

  describe :guest_user do
    context 'with default/no parameter specified' do
      let(:result) { obj.guest_user }

      it_behaves_like 'a result with a Guest User entity'

      it 'includes the password fields in the Guest User entity' do
        expect(result.entity.password).not_to be_empty
        expect(result.entity.password_confirmation).not_to be_empty
      end
    end # context 'with default/no parameter specified'

    context 'with :no_password option specified' do
      let(:result) { obj.guest_user :no_password }

      it_behaves_like 'a result with a Guest User entity'

      it 'does NOT include the password fields in the Guest User entity' do
        expect(result.entity.password).to be_nil
        expect(result.entity.password_confirmation).to be_nil
      end
    end # context 'with :no_password option specified' do
  end # describe :guest_user
end # describe UserRepository
