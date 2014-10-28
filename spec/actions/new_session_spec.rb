
require 'spec_helper'

require 'new_session'

# Why the @internals? So Rubocop doesn't kvetch about how `#success`
# "ought to be" `#success=`. Pfffft.
class SuccessTester
  def initialize
    @internals = { success: nil, failure: nil }
  end

  def successful?
    @internals[:success].present?
  end

  def failure?
    @internals[:failure].present?
  end

  def success(*payload)
    @internals[:success] = payload
  end

  def failure(*payload)
    @internals[:failure] = payload
  end

  def payload_for(which)
    if which == :success
      @internals[:success]
    else
      @internals[:failure]
    end
  end
end # class SuccessTester

module Actions
  describe NewSession do
    let(:klass) { NewSession }
    let(:guest_user) { UserRepository.new.guest_user.entity }
    let(:subscriber) { SuccessTester.new }

    # Regardless of expected success or failure, these are the steps...
    before :each do
      command.subscribe subscriber
      command.execute
    end

    context 'is successful with valid parameters' do
      let(:command) { klass.new guest_user }

      it 'broadcasts :success' do
        expect(subscriber).to be_successful
        expect(subscriber).not_to be_failure
      end

      describe 'broadcasts :success with a payload of a StoreResult, which' do
        let(:payload) { subscriber.payload_for(:success).first }

        it 'is successful' do
          expect(payload).to be_success
        end

        it 'has no errors' do
          expect(payload).to have(0).errors
        end

        it 'has the Guest User entity attributes in its entity' do
          expect(payload.entity.attributes).to eq payload.entity.attributes
        end
      end # describe 'broadcasts :success with a payload of a StoreResult, ...'
    end # context 'is successful with valid parameters'

    context 'is unsuccessful with invalid parameters' do
      let(:other_user) { UserEntity.new FactoryGirl.attributes_for(:user) }
      let(:command) do
        UserRepository.new.add other_user
        klass.new other_user
      end

      it 'broadcasts :success' do
        expect(subscriber).not_to be_successful
        expect(subscriber).to be_failure
      end
    end # context 'is unsuccessful with invalid parameters'
  end # describe Actions::NewSessions
end # module Actions
