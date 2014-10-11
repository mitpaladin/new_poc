
require 'spec_helper'

describe UserRepository do
  let(:klass) { UserRepository }
  let(:obj) { klass.new }
  let(:user_name) { 'Joe Blow' }
  let(:email) { 'jblow@example.com' }
  let(:password) { 'password' }
  let(:entity) do
    UserEntity.new name: user_name, slug: user_name.parameterize,
                   email: email, profile: '*This* is a profile?!?',
                   password: password, password_confirmation: password
  end
  let(:save_error_data) { { frobulator: 'is busted' } }
  let(:record_errors) do
    e = ActiveModel::Errors.new(obj)
    e.add save_error_data.keys.first, save_error_data.values.first
    e
  end

  describe :initialize.to_s do
    it 'can be called without parameters' do
      expect { klass.new }.not_to raise_error
    end
  end # describe :initialize

  describe :add.to_s do

    context 'on success' do
      let!(:result) { obj.add entity }

      it 'adds a new record to the database' do
        expect(UserDao.all).to have(1).record
      end

      it 'returns the expected StoreResult' do
        expect(result).to be_success
        expect(result.errors).to be nil
        expect(result.entity).to be_saved_entity_for entity
      end
    end # context 'on success'

    context 'on failure' do
      let(:mockDao) do
        Class.new(UserDao) do
          def save
            errors.add :frobulator, 'is busted'
            false
          end
        end
      end
      let(:obj) do
        klass.new UserFactory, mockDao
      end
      let(:result) { obj.add entity }

      it 'does not add a new record to the database' do
        expect(UserDao.all).to have(0).records
      end

      it 'returns the expected StoreResult' do
        expect(result).not_to be_success
        expect(result.entity).to be nil
        expect(result).to have(1).error
        error = result.errors.first
        expect(error[:field]).to eq save_error_data.keys.first.to_s
        expect(error[:message]).to eq save_error_data.values.first
      end
    end # context 'on failure'
  end # describe :add

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
        expect(UserDao.last.profile).to eq updated_profile
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
        Class.new(UserDao) do
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
        expect(UserDao.last.profile).not_to eq updated_profile
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
        errors = ActiveModel::Errors.new UserDao.new
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
        expect(UserDao.last.profile).not_to eq updated_profile
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
        expect(result.entity).to be_saved_entity_for entity
      end
    end # context 'record exists'
  end # describe :find_by_slug

end # describe UserRepository
