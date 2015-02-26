
require 'spec_helper'
require 'current_user_identity'
require 'support/broadcast_success_tester'

describe PostsController::Action::Create do
  let(:repo) { UserRepository.new }
  # NOTE: Old `Actions` namespace currently used here. Oops.
  let(:subscriber) { Actions::BroadcastSuccessTester.new }
  let(:current_user) do
    attribs = FactoryGirl.attributes_for :user, :saved_user
    user = Newpoc::Entity::User.new attribs
    repo.add user
    user
  end
  let(:guest_user) { repo.guest_user.entity }

  # regardless of parameters, these steps wire up the Wisper connection
  before :each do
    command.subscribe(subscriber).execute
  end

  context 'with the Guest User as the current user' do
    let(:command) do
      described_class.new current_user: repo.guest_user.entity,
                          post_data: post_data
    end
    let(:post_data) { { title: 'A Title', body: 'A Body' } }
    let(:message) { 'Not logged in as a registered user!' }

    it 'is unsuccessful' do
      expect(subscriber).not_to be_successful
      expect(subscriber).to be_failure
    end

    describe 'is unsuccessful, broadcasting a payload with' do
      let(:payload) { subscriber.payload_for(:failure).first }

      it 'the expected error' do
        expect(payload).to respond_to :exception
        exception = YAML.load payload.message
        expect(exception[:messages].first).to eq message
      end
    end # describe 'is unsuccessful, broadcasting a payload with'
  end # context 'with the Guest User as the current user'

  context 'with a Registered User as the current user' do
    let(:command) do
      described_class.new current_user: current_user,
                          post_data: post_data
    end

    context 'with minimal valid post data' do
      let(:post_data) do
        {
          author_name: current_user.name,
          title: 'A Title',
          body: 'A Body'
        }
      end

      # it_behaves_like 'a successful post'
      it 'is successful' do
        expect(subscriber).to be_successful
        expect(subscriber).not_to be_failure
      end

      describe 'is successful, broadcasting a Newpoc::Entity::Post payload' do
        let(:payload) { subscriber.payload_for(:success).first }

        it 'which is valid' do
          expect(payload).to be_valid
        end

        it 'with the correct field values set' do
          acceptable_keys = [
            :body,
            :created_at,
            :image_url,
            :slug,
            :title,
            :updated_at
          ]
          expected = post_data.select { |k, _v| acceptable_keys.include? k }
                     .merge author_name: current_user.name

          expect(payload).to be_a Newpoc::Entity::Post
          expected.each do |attrib, value|
            expect(payload.attributes[attrib]).to eq value
          end
        end
      end # describe 'is successful, broadcasting a ... payload'
    end # context 'with minimal valid post data'
  end # context 'with a Registered User as the current user'
end # describe PostsController::Action::Create
