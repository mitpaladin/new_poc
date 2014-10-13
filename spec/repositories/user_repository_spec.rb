
require 'spec_helper'

require_relative 'shared_examples/the_initialize_method_for_a_repository'
require_relative 'shared_examples/the_add_method_for_a_repository'

describe UserRepository do
  let(:klass) { UserRepository }
  let(:be_entity_for) do
    ->(entity) { be_saved_user_entity_for(entity) }
  end
  let(:dao_class) { UserDao }
  let(:factory_class) { UserFactory }
  let(:obj) { klass.new }
  let(:user_name) { 'Joe Blow' }
  let(:email) { 'jblow@example.com' }
  let(:password) { 'password' }
  let(:entity) do
    UserEntity.new FactoryGirl.attributes_for(:user, :saved_user)
  end
  let(:save_error_data) { { frobulator: 'is busted' } }
  let(:record_errors) do
    e = ActiveModel::Errors.new(obj)
    e.add save_error_data.keys.first, save_error_data.values.first
    e
  end

  describe :initialize.to_s do
    it_behaves_like 'the #initialize method for a Repository'
  end # describe :initialize

  describe :add.to_s do
    it_behaves_like 'the #add method for a Repository'
  end # describe :add

  describe :all.to_s do

    context 'when users have been added' do
      let(:user_count) { 3 }
      let(:result) do
        attrib_list = FactoryGirl.attributes_for_list :user, user_count,
                                                      :saved_user
        attrib_list.each { |attribs| obj.add UserEntity.new(attribs) }
        obj.all
      end

      describe 'returns an array' do
        it 'whose length is the number of records in the User DAO' do
          expect(result.count).to eq dao_class.all.count
        end

        describe 'with items' do

          it 'that are UserEntity instances' do
            result.each { |record| expect(record).to be_a UserEntity }
          end

          describe 'where each UserEntity' do
            it 'corresponds to a valid UserDao instance' do
              result.each do |record|
                dao_record = dao_class.find_by_slug record.slug
                expect(dao_record).to be_valid
              end
            end

            it 'has a unique slug' do
              slugs = []
              result.each do |record|
                slugs << record.slug unless slugs.include?(record.slug)
              end
              expect(slugs.count).to eq result.count
            end
          end # describe 'where each UserEntity'
        end # describe 'with items'
      end # describe 'returns an array'
    end # context 'when users have been added'

    context 'when no users have yet been added' do
      let(:result) { obj.all }

      it 'returns an empty Array' do
        expect(result).to be_an Array
        expect(result).to be_empty
      end
    end
  end # describe :all

  describe :delete.to_s do

    context 'for an existing user' do
      let(:result) do
        attribs = FactoryGirl.attributes_for :user, :saved_user
        obj.add UserEntity.new attribs
        obj.delete attribs[:slug]
      end

      it 'returns the expected StoreResult' do
        expect(result).to be_success
        expect(result.entity).to be nil
        expect(result.errors).to be nil
      end
    end # context 'for an existing user'

    context 'for a nonexistent user' do
      let(:result) { obj.delete 'nothing-here' }

      it 'returns the expected StoreResult' do
        expect(result).not_to be_success
        expect(result.entity).to be nil
        message = "A record with 'slug'=nothing-here was not found."
        expect(result.errors.first).to be_an_error_hash_for :base, message
      end
    end # context 'for a nonexistent user'
  end # describe :delete

  describe :find_by_slug.to_s do

    context 'record not found' do

      it 'returns the expected StoreResult' do
        result = obj.find_by_slug :nothing_here
        expect(result).not_to be_success
        expect(result.entity).to be nil
        expect(result).to have(1).error
        expected_message = "A record with 'slug'=nothing_here was not found."
        expect(result.errors.first)
            .to be_an_error_hash_for :base, expected_message
      end
    end # context 'record not found'

    context 'record exists' do
      let(:result) do
        obj.add entity
        obj.find_by_slug entity.slug
      end

      it 'returns the expected StoreResult' do
        expect(result).to be_success
        expect(result.errors).to be nil
        expect(result.entity).to be_a UserEntity
        expect(result.entity).to be_saved_user_entity_for entity
      end
    end # context 'record exists'
  end # describe :find_by_slug

  describe :update.to_s do
    let(:updated_profile) { '*Updated* meaningless profile.' }

    context 'on success' do
      let!(:result) do
        r = obj.add entity
        entity = r.entity
        attribs = entity.attributes
        attribs[:profile] = updated_profile
        entity = UserEntity.new attribs
        obj.update entity
      end

      it 'updates the stored record' do
        expect(dao_class.last.profile).to eq updated_profile
      end

      it 'returns the expected StoreResult' do
        expect(result).to be_success
        expect(result.errors).to be nil
        expect(result.entity.profile).to eq updated_profile
      end
    end # context 'on success'

    context 'on failure' do
      let(:error_key) { :frobulator }
      let(:error_message) { 'is busted' }
      let(:mockDao) do
        Class.new(dao_class) do
          def update_attributes(_attribs)
            # And no, this can't use RSpec variables declared earlier. Pffft.
            errors.add :frobulator, 'is busted'
            false
          end
        end
      end
      let(:obj) do
        klass.new UserFactory, mockDao
      end
      let!(:result) do
        r = obj.add entity
        entity = r.entity
        attribs = entity.attributes
        attribs[:profile] = updated_profile
        entity = UserEntity.new attribs
        obj.update entity
      end

      it 'does not update the stored record' do
        expect(dao_class.last.profile).not_to eq updated_profile
      end

      it 'returns the expected StoreResult' do
        expect(result).not_to be_success
        expect(result.entity).to be nil
        expect(result).to have(1).error
        expect(result.errors.first)
            .to be_an_error_hash_for error_key, error_message
      end
    end # context 'on failure'

    context 'on the record not being found' do
      let(:bad_slug_return) do
        errors = ActiveModel::Errors.new dao_class.new
        errors.add :base, "A record with 'slug'=#{user_name.parameterize} was" \
            ' not found.'
        StoreResult.new entity: nil, success: false,
            errors: ErrorFactory.create(errors)
      end
      let(:obj) do
        ret = klass.new
        allow(ret).to receive(:find_by_slug).and_return bad_slug_return
        ret
      end
      let!(:result) do
        r = obj.add entity
        entity = r.entity
        attribs = entity.attributes
        attribs[:profile] = updated_profile
        entity = UserEntity.new attribs
        obj.update entity
      end

      it 'does not update the stored record' do
        expect(dao_class.last.profile).not_to eq updated_profile
      end

      it 'returns the expected StoreResult' do
        expect(result).not_to be_success
        expect(result.entity).to be nil
        expect(result).to have(1).error
        expected_message = "A record with 'slug'=joe-blow was not found."
        expect(result.errors.first)
            .to be_an_error_hash_for :base, expected_message
      end
    end # context 'on the record not being found'
  end
end # describe delete
