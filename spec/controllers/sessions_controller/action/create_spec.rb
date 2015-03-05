
require 'spec_helper'
require 'wisper_subscription'

describe SessionsController::Action::Create do
  let(:command) do
    described_class.new name: user.name, password: user.password,
                        repository: repo
  end
  let(:subscriber) { WisperSubscription.new }
  let(:user) { FancyOpenStruct.new name: 'Name', passsword: 'Password' }

  before :each do
    subscriber.define_message :success
    subscriber.define_message :failure
    command.subscribe(subscriber).execute
  end

  context 'is successful with valid parameters, broadcasting' do
    let(:repo) do
      Class.new do
        def authenticate(_user_name, _password)
          FancyOpenStruct.new :success? => true, entity: 'valid_entity'
        end
      end.new
    end
    let(:valid_entity) { 'valid_entity' }

    it ':success' do
      expect(subscriber).to be_success
    end

    describe ':success with a payload which' do
      let(:payload) { subscriber.payload_for :success }

      it 'contains the entity value returned by the repo #authenticate call' do
        expect(payload).to eq [valid_entity]
      end
    end # describe ':success with a payload which'
  end # context 'is successful with valid parameters, broadcasting'

  context 'is unsuccessful with invalid parameters, broadcasting' do
    let(:repo) do
      Class.new do
        def authenticate(_user_name, _password)
          error = FancyOpenStruct.new message: 'Invalid user name or password'
          FancyOpenStruct.new :failure? => true, entity: nil,
                              errors: [error]
        end
      end.new
    end

    it 'failure' do
      expect(subscriber).to be_failure
    end

    describe ':failure with a payload which' do
      let(:payload) { subscriber.payload_for :failure }

      it 'is the correct error message' do
        expect(payload).to eq ['Invalid user name or password']
      end
    end # describe ':failure with a payload which'
  end # context 'is unsuccessful with invalid parameters, broadcasting'
end # describe SessionsController::Action::Create
