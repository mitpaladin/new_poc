
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
  let(:be_entity_for) do
    ->(entity) { be_saved_user_entity_for(entity) }
  end
  let(:dao_class) { UserDao }
  let(:factory_class) { UserFactory }
  let(:entity_class) { UserFactory.entity_class }
  let(:obj) { described_class.new }
  let(:user_name) { 'Joe Blow' }
  let(:email) { 'jblow@example.com' }
  let(:password) { 'password' }
  let(:entity_attributes) do
    FactoryGirl.attributes_for :user, :saved_user
  end
  let(:entity) do
    UserPasswordEntityFactory.create entity_attributes, 'password'
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

  # describe :delete.to_s do
  #   it_behaves_like 'the #delete method for a Repository'
  # end # describe :delete

  describe :find_by_slug.to_s do
    it_behaves_like 'the #find_by_slug method for a Repository'
  end # describe :find_by_slug

  describe :update.to_s do
    let(:attribute_to_update) { :profile }
    let(:updated_attribute) { '*Updated* meaningless profile.' }

    it_behaves_like 'the #update method for a Repository'
  end # describe :update'

  describe :attributes_for.to_s do
    context 'for a dao with no passwords' do
      it 'adds test password' do
        dao = FactoryGirl.create :user
        attr = UserRepository.new.send(:attributes_for, dao, [])
        expect(attr[:password]).to eq 'password'
      end

      it 'adds no test password per instruction' do
        dao = FactoryGirl.create :user
        attr = UserRepository.new.send(:attributes_for, dao, [:no_password])
        expect(attr[:password]).to be_nil
      end
    end
  end

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

          # FIXME: This ought to have a a custom matcher.
          it 'an "entity" field with the correct attributes' do
            [:email, :name, :profile, :slug].each do |attr|
              expect(result.entity.send attr).to eq dao[attr]
            end
            [:created_at, :updated_at].each do |attr|
              actual = result.entity.send attr
              expect(actual).to be_within(5.seconds).of dao[attr]
            end
          end
        end # describe 'it returns a StoreResult with'
      end # context 'with a correct password'
    end # context 'for an existing user'
  end # describe :authenticate
end # describe UserRepository
