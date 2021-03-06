
require 'spec_helper'
require 'current_user_identity'
require 'support/broadcast_success_tester'

shared_examples 'a successful post that' do
  it 'is successful' do
    expect(subscriber).to be_successful
    expect(subscriber).not_to be_failure
  end

  describe 'is successful, broadcasting a Post-entity payload' do
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
      expected = post_data
                 .select { |k, _v| acceptable_keys.include? k }
                 .merge author_name: current_user.name

      expect(payload).to be_a PostFactory.entity_class
      expected.each do |attrib, value|
        expect(payload.attributes.to_hash[attrib]).to eq value
      end
    end
  end # describe 'is successful, broadcasting a Post-entity payload'
end # shared_examples 'a successful post that'

# ############################################################################ #
# ############################################################################ #
# ############################################################################ #

describe PostsController::Action::Create do
  let(:repo) { UserRepository.new }
  # NOTE: Old `Actions` namespace currently used here. Oops.
  let(:subscriber) { Actions::BroadcastSuccessTester.new }
  let(:current_user) do
    FactoryGirl.build_stubbed :user, :saved_user
  end
  let(:guest_user) do
    UserDao.first
  end

  # regardless of parameters, these steps wire up the Wisper connection
  before :each do
    command.subscribe(subscriber).execute
  end

  context 'with the Guest User as the current user' do
    let(:command) do
      described_class.new current_user: guest_user,
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

      it_behaves_like 'a successful post that'
    end # context 'with minimal valid post data'

    context 'with additional valid post data' do
      let(:post_data) do
        {
          author_name: current_user.name,
          title: 'A Title',
          body: 'A Body',
          image_url: 'http://example.com/image1.png'
        }
      end

      it_behaves_like 'a successful post that'
    end # context 'with additional valid post data'

    context 'with additional but invalid post data' do
      let(:valid_data) do
        {
          author_name: current_user.name,
          title: 'A Title',
          body: 'A Body',
          image_url: 'http://example.com/image1.png'
        }
      end
      let(:invalid_data) { { bogus: 'an invalid post data attribute' } }
      let(:post_data) { valid_data.merge invalid_data }

      it_behaves_like 'a successful post that'

      it 'does not include any invalid initialiser settings' do
        payload = subscriber.payload_for(:success).first
        invalid_data.each_key do |k|
          expect(payload.attributes.to_hash).not_to include k
        end
      end
    end # context 'with additional but invalid post data'

    context 'with post status set to' do
      let(:actual) { subscriber.payload_for(:success).first }

      context 'draft' do
        let(:post_data) do
          {
            author_name: current_user.name,
            title: 'A Title',
            body: 'A Body'
            # post_status: 'draft'
          }
        end

        it_behaves_like 'a successful post that'

        it 'is a draft post' do
          expect(actual).to be_draft
        end
      end # context 'draft'

      context 'public' do
        let(:post_data) do
          {
            author_name: current_user.name,
            title: 'A Title',
            body: 'A Body',
            pubdate: Time.zone.now
            # post_status: 'public'
          }
        end

        it_behaves_like 'a successful post that'

        it 'is not a draft post' do
          expect(actual).not_to be_draft
        end
      end # context 'public'
    end # context 'with post status set to'

    context 'with insufficient valid post data' do
      let(:post_data) { { body: 'A Body All Alone' } }

      it 'is unsuccessful' do
        expect(subscriber).not_to be_successful
        expect(subscriber).to be_failure
      end

      describe 'is unsuccessful, broadcasting a payload with' do
        let(:payload) { subscriber.payload_for(:failure).first }

        def entity_attributes(json_string)
          data = JSON.parse(json_string).deep_symbolize_keys
          return data[:attributes] if data.key? :attributes
          data
        end

        it 'the expected errors' do
          entity = PostFactory.create entity_attributes(payload.message)
          expect(entity).not_to be_valid
          expect(entity).to have(1).error
          message = entity.errors.full_messages.first
          # FIXME: Changes!
          acceptable = [
            "Title can't be blank",  # old entity
            'Title must be present'  # new entity
          ]
          expect(acceptable).to include message
        end
      end # describe 'is unsuccessful, broadcasting a payload with'
    end # context 'with insufficient valid post data'
  end # context 'with a Registered User as the current user'
end # describe PostsController::Action::Create
