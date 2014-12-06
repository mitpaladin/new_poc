
require 'spec_helper'

require 'create_post'

require 'main_logger'

shared_examples 'a successful post' do
  it 'is successful' do
    expect(subscriber).to be_successful
    expect(subscriber).not_to be_failure
  end

  describe 'is successful, broadcasting a PostEntity payload' do
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

      expect(payload).to be_a PostEntity
      expected.each do |attrib, value|
        expect(payload.attributes[attrib]).to eq value
      end
    end
  end # describe 'is successful, broadcasting a PostEntity payloadh'
end # shared_examples 'a successful post'

# ############################################################################ #
# ############################################################################ #
# ############################################################################ #

module Actions
  describe CreatePost do
    let(:klass) { CreatePost }
    let(:repo) { UserRepository.new }
    let(:subscriber) { BroadcastSuccessTester.new }
    let(:current_user) do
      user = UserEntity.new FactoryGirl.attributes_for :user, :saved_user
      repo.add user
      user
    end
    let(:guest_user) { repo.guest_user.entity }

    before :each do
      command.subscribe subscriber
      command.execute
    end

    context 'with the Guest User as the current user' do
      let(:command) { klass.new repo.guest_user.entity, post_data }
      let(:post_data) { { title: 'A Title', body: 'A Body' } }
      let(:message) { 'Not logged in as a registered user!' }

      it 'is unsuccessful' do
        expect(subscriber).not_to be_successful
        expect(subscriber).to be_failure
      end

      describe 'is unsuccessful, broadcasting a payload with' do
        let(:payload) { subscriber.payload_for(:failure).first }

        it 'the expected error' do
          expect(payload.message).to eq message.to_json
        end
      end # describe 'is unsuccessful, broadcasting a payload with'
    end # context 'with the Guest User as the current user'

    context 'with a Registered User as the current user' do
      let(:command) { klass.new current_user, post_data }

      context 'with minimal valid post data' do
        let(:post_data) do
          {
            author_name: current_user.name,
            title: 'A Title',
            body: 'A Body'
          }
        end

        it_behaves_like 'a successful post'
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

        it_behaves_like 'a successful post'
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

        it_behaves_like 'a successful post'

        it 'does not include any invalid initialiser settings' do
          payload = subscriber.payload_for(:success).first
          invalid_data.each_key do |k|
            expect(payload.attributes).not_to include k
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
              body: 'A Body',
              post_status: 'draft'
            }
          end

          it_behaves_like 'a successful post'

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
              post_status: 'public'
            }
          end

          it_behaves_like 'a successful post'

          it 'is not a draft post' do
            expect(actual).not_to be_draft
          end
        end # context 'public'
      end # context 'with post status set to'

      context 'with insufficient valid post data' do
        let(:post_data) { { body: 'A Body' } }

        it 'is unsuccessful' do
          expect(subscriber).not_to be_successful
          expect(subscriber).to be_failure
        end

        describe 'is unsuccessful, broadcasting a payload with' do
          let(:payload) { subscriber.payload_for(:failure).first }

          it 'the expected errors' do
            attribs = JSON.parse(payload.message).symbolize_keys
            entity = PostEntity.new attribs
            expect(entity).not_to be_valid
            expect(entity).to have(1).error
            messages = entity.errors.full_messages
            expect(messages).to include "Title can't be blank"
          end
        end # describe 'is unsuccessful, broadcasting a payload with'
      end # context 'with insufficient valid post data'
    end # context 'with a Registered User as the current user'
  end # describe Actions::CreatePost
end # module Actions
