
require 'spec_helper'

describe UserRepository do
  let(:klass) { UserRepository }

  describe :initialize.to_s do
    it 'can be called without parameters' do
      expect { klass.new }.not_to raise_error
    end
  end # describe :initialize

  describe :add.to_s do
    let(:obj) { klass.new }
    let(:user_name) { 'Joe Blow' }
    let(:email) { 'jblow@example.com' }
    let(:password) { 'password' }
    let(:entity) do
      UserEntity.new name: user_name, slug: user_name.parameterize,
                     email: email, profile: '*This* is a profile?!?',
                     password: password, password_confirmation: password
    end

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
      let(:record_errors) do
        [{ field: 'defrobulator', message: 'Save attempt blew it up. Sorry.' }]
      end
      let(:bad_record) do
        FancyOpenStruct.new save: false, errors: record_errors
      end
      let(:result) { obj.add entity }

      before :each do
        allow(UserDao).to receive(:new).and_return bad_record
      end

      it 'does not add a new record to the database' do
        expect(UserDao.all).to have(0).records
      end

      it 'returns the expected StoreResult' do
        expect(result).not_to be_success
        expect(result.entity).to be nil
        expect(result).to have(1).error
        expect(result.errors).to eq record_errors
      end
    end # context 'on failure'
  end # describe add
end # describe UserRepository
