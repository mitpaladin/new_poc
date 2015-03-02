
require 'spec_helper'
require 'fancy-open-struct'
require 'wisper_subscription'

describe UsersController::Action::New do
  let(:command) do
    described_class.new current_user: current_user, user_repo: repo
  end
  let(:guest_user) { FancyOpenStruct.new name: 'Guest User' }
  let(:registered_user) { FancyOpenStruct.new name: 'User Name' }
  let(:repo) do
    guest = FancyOpenStruct.new entity: guest_user
    FancyOpenStruct.new guest_user: guest
  end
  let(:subscriber) { WisperSubscription.new }

  before :each do
    subscriber.define_message :success
    subscriber.define_message :failure
    command.subscribe subscriber
    command.execute
  end

  context 'when no user is currently logged in, it' do
    let(:current_user) { guest_user }

    it 'broadcasts :success' do
      expect(subscriber).to be_success
    end

    describe 'broadcasts :success with an entity payload containing' do
      let(:payload) { subscriber.payload_for(:success).first }

      it 'an empty :profile string' do
        expect(payload.profile).to respond_to :to_str
        expect(payload.profile).to be_empty
      end

      it 'the :created_at timestamp with the current time' do
        expected = Time.current.localtime
        expect(payload.created_at).to be_within(0.5.seconds).of expected
      end

      [:name, :email, :slug, :updated_at].each do |attrib|
        it "an :#{attrib} value of nil" do
          expect(payload.attributes[attrib]).to be nil
        end
      end
    end # describe 'broadcasts :success with an entity payload containing'
  end # context 'when no user is currently logged in'

  context 'when a registered user is logged in, it' do
    let(:current_user) { registered_user }

    it 'broadcasts :failure' do
      expect(subscriber).to be_failure
    end

    describe 'broadcasts :failure with a payload which' do
      let(:payload) { subscriber.payload_for(:failure).first }

      it 'is an entity naming the currently logged-in user' do
        expect(payload.name).to eq registered_user.name
      end
    end
  end # context 'when a registered user is logged in'
end # describe UsersController::Action::New
