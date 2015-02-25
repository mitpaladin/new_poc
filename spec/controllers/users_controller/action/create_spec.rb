
require 'spec_helper'
require 'current_user_identity'
require 'support/broadcast_success_tester'

describe UsersController::Action::Create do
  let(:guest_user) { UserRepository.new.guest_user.entity }
  # NOTE: Old `Actions` namespace currently used here. Oops.
  let(:subscriber) { Actions::BroadcastSuccessTester.new }
  let(:user_data) do
    FancyOpenStruct.new FactoryGirl.attributes_for(:user, :saved_user)
  end
  let(:user_entity_class) { Newpoc::Entity::User }

  # regardless of parameters, these steps wire up the Wisper connection
  before :each do
    command.subscribe(subscriber).execute
  end

  context 'is successful with valid parameters' do
    let(:command) { described_class.new guest_user, user_data }

    it 'broadcasts success' do
      expect(subscriber).to be_successful
    end

    describe 'broadcasts :success with a payload of a StoreResult, which' do
      let(:payload) { subscriber.payload_for(:success).first }

      it 'is a User instance' do
        expect(payload).to be_a user_entity_class
      end

      it 'has the new user entity attributes in its entity' do
        expect(payload).to be_saved_user_entity_for user_data
      end
    end # describe 'broadcasts :success with a payload of a StoreResult, which'
  end # context 'is successful with valid parameters'

  context 'is unsuccessful with parameters that are invalid because' do
    let(:user_repository) { UserRepository.new }
    let(:user_attribs) { FactoryGirl.attributes_for :user }

    context 'the request is made from a logged-in user session' do
      let(:command) { described_class.new current_user, user_data }
      let(:current_user) do
        entity = UserPasswordEntityFactory.create user_attribs, 'password'
        user_repository.add(entity).entity
      end

      describe 'and broadcasts :failure with a payload of a YAML Hash' do
        let(:data) { FancyOpenStruct.new YAML.load(payload) }
        let(:payload) { subscriber.payload_for(:failure).first }

        it 'with one key, :messages' do
          expect(data.keys).to eq [:messages]
        end

        it 'with a single :messages array item with the error message' do
          expect(data).to have(1).message
          expected = "Already logged in as #{current_user.name}!"
          expect(data.messages.first).to eq expected
        end
      end # describe 'and broadcasts :failure with a payload of a YAML Hash'
    end # context 'the request is made from a logged-in user session'

    context 'the named user already exists' do
      let(:command) { described_class.new guest_user, other_user.attributes }
      let(:other_user) do
        user = UserPasswordEntityFactory.create user_attribs, 'password'
        user_repository.add user
        user
      end

      describe 'and broadcasts :failure with a payload of a YAML Hash' do
        let(:data) { FancyOpenStruct.new YAML.load(payload) }
        let(:payload) { subscriber.payload_for(:failure).first }

        it 'with two keys, :attributes and :messages' do
          expected_keys = [:attributes, :messages]
          expect(data.keys.sort).to eq expected_keys.sort
        end

        it 'with an :attributes hash containing the specified attributes' do
          these_values = data[:attributes].symbolize_keys
          other_values = other_user.attributes
          other_values.delete :slug
          expect(these_values).to eq other_values
        end

        it 'with a :messages array containing the error message' do
          expect(data).to have(1).message
          expected = ['A record identified by slug',
                      "'#{user_attribs[:name].parameterize}'",
                      'already exists!'].join(' ')
          expect(data.messages.first).to eq expected
        end
      end # describe 'and broadcasts :failure with a payload of a YAML Hash'
    end # context 'the named user already exists'

    context 'the user name is invalid' do
      let(:command) { described_class.new guest_user, user.attributes }
      let(:user) do
        user = UserPasswordEntityFactory.create user_attribs, 'password'
        user_repository.add user
        user
      end
      let(:user_attribs) { FactoryGirl.attributes_for :user, name: '  Joe ' }

      describe 'and broadcasts :failure with a payload of a YAML Hash' do
        let(:data) { FancyOpenStruct.new YAML.load(payload) }
        let(:payload) { subscriber.payload_for(:failure).first }

        it 'with two keys, :attributes and :messages' do
          expect(data.keys.sort).to eq [:attributes, :messages]
        end

        it 'with an :attributes hash containing the specified attributes' do
          actual = data[:attributes]
          expect(actual[:created_at]).to respond_to :to_time
          actual.delete :created_at
          actual.delete :updated_at
          user_data.delete :slug
          expect(actual.to_h).to eq user_attribs
        end

        it 'with a :messages array containing the error messages' do
          # expect(data).to have(2).messages
          expected_format = 'Name may not have %s whitespace'
          %w(leading trailing).each do |space_type|
            expected = format expected_format, space_type
            expect(data[:messages]).to include expected
          end
        end
      end # describe 'and broadcasts :failure with a payload of a YAML Hash'
    end # context 'the user name is invalid'
  end # context 'is unsuccessful with parameters that are invalid because'
end # describe UsersController::Action::Create
