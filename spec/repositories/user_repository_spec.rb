
require 'spec_helper'

require_relative 'shared_examples/the_initialize_method_for_a_repository'
require_relative 'shared_examples/the_add_method_for_a_repository'
require_relative 'shared_examples/the_all_method_for_a_repository'
require_relative 'shared_examples/the_delete_method_for_a_repository'
require_relative 'shared_examples/the_find_by_slug_method_for_a_repository'
require_relative 'shared_examples/the_update_method_for_a_repository'

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

  describe :initialize.to_s do
    it_behaves_like 'the #initialize method for a Repository'
  end # describe :initialize

  describe :add.to_s do
    it_behaves_like 'the #add method for a Repository'
  end # describe :add

  describe :all.to_s do
    it_behaves_like 'the #all method for a Repository'
  end # describe :all

  describe :delete.to_s do
    it_behaves_like 'the #delete method for a Repository'
  end # describe :delete

  describe :find_by_slug.to_s do
    it_behaves_like 'the #find_by_slug method for a Repository'
  end # describe :find_by_slug

  describe :update.to_s do
    let(:attribute_to_update) { :profile }
    let(:updated_attribute) { '*Updated* meaningless profile.' }

    it_behaves_like 'the #update method for a Repository'
  end # describe :update
end # describe UserRepository
