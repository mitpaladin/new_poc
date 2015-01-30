
require 'spec_helper'
require 'wisper_subscription'

require_relative '../repositories/custom_matchers/be_same_timestamped_entity_as'

require 'index_users'

# Short and sweet. There are presently no parameters or failure case defined.

describe Newpoc::Actions::Users::Index do
  let(:repo) { UserRepository.new }
  let(:subscriber) { WisperSubscription.new }
  let(:user_count) { 5 }
  let(:users) { [] }
  let(:command) { described_class.new UserRepository.new }

  before :each do
    user_count.times do
      attribs = FactoryGirl.attributes_for :user, :saved_user
      user = UserPasswordEntityFactory.create attribs, 'password'
      repo.add user
      users << user
    end
    subscriber.define_message :success
    subscriber.define_message :failure
    command.subscribe subscriber
    command.execute
  end

  it 'is successful' do
    expect(subscriber).to be_success
    expect(subscriber).not_to be_failure
  end

  describe 'is successful, broadcasting a payload which' do
    let(:payload) { subscriber.payload_for(:success).first }

    it 'is an enumeration of UserEntity instances' do
      expect(payload).to be_an Enumerable
      entity_class = Newpoc::Entity::User
      payload.each { |user_item| expect(user_item).to be_a entity_class }
    end

    it 'has the correct number of entities' do
      expect(payload.count).to eq users.count
    end

    it 'has the same entities in the same order as those added' do
      users.each_with_index do |user, index|
        expect(payload[index]).to be_same_timestamped_entity_as user
      end
    end
  end # describe 'is successful, broadcasting a payload which'
end # describe Newpoc::Actions::Users::Index
