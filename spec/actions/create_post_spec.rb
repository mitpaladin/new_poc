
require 'spec_helper'

require 'create_post'

shared_examples 'a successful post' do
  it 'is successful' do
    expect(subscriber).to be_successful
    expect(subscriber).not_to be_failure
  end

  describe 'is successful, broadcasting a StoreResult payload with' do
    let(:payload) { subscriber.payload_for(:success).first }

    it 'a :success value of true' do
      expect(payload).to be_success
    end

    it 'an empty :errors item' do
      expect(payload.errors).to be_empty
    end

    description = 'a PostEntity instance for an :entity value, with the' \
        ' correct field values set'
    it description do
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

      expect(payload.entity).to be_a PostEntity
      expected.each do |attrib, value|
        expect(payload.entity.attributes[attrib]).to eq value
      end
    end
  end # describe 'is successful, broadcasting a StoreResult payload with'
end # shared_examples 'a successful post'

shared_examples 'an unsuccessful post' do |error_field, error_message|
  it 'is unsuccessful' do
    expect(subscriber).not_to be_successful
    expect(subscriber).to be_failure
  end

  describe 'is unsuccessful, broadcasting a StoreResult payload with' do
    let(:payload) { subscriber.payload_for(:failure).first }

    it 'a :success value of false' do
      expect(payload).not_to be_success
    end

    it 'a correct :errors item' do
      expect(payload).to have(1).error
      expect(payload.errors.first)
          .to be_an_error_hash_for error_field, error_message
    end

    it 'an :entity value of nil' do
      expect(payload.entity).to be nil
    end
  end # describe 'is unsuccessful, broadcasting a StoreResult payload...'
end

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

      message = 'Not logged in as a registered user!'
      it_behaves_like 'an unsuccessful post', :user, message
    end # context 'with the Guest User as the current user'

    context 'with a Registered User as the current user' do
      let(:command) { klass.new current_user, post_data }

      context 'with minimal valid post data' do
        let(:post_data) { { title: 'A Title', body: 'A Body' } }

        it_behaves_like 'a successful post'
      end # context 'with minimal valid post data'

      context 'with additional valid post data' do
        let(:post_data) do
          {
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
            title: 'A Title',
            body: 'A Body',
            image_url: 'http://example.com/image1.png'
          }
        end
        let(:invalid_data) { { bogus: 'an invalid post data attribute' } }
        let(:post_data) { valid_data.merge invalid_data }

        it_behaves_like 'a successful post'

        it 'does not include any invalid initialiser settings' do
          payload = subscriber.payload_for(:success).first.entity
          invalid_data.each_key do |k|
            expect(payload.attributes).not_to include k
          end
        end
      end # context 'with additional but invalid post data'

      context 'with post status set to' do
        let(:actual) { subscriber.payload_for(:success).first.entity }

        context 'draft' do
          let(:post_data) do
            { title: 'A Title', body: 'A Body', post_status: 'draft' }
          end

          it_behaves_like 'a successful post'

          it 'is a draft post' do
            expect(actual).to be_draft
          end
        end # context 'draft'

        context 'public' do
          let(:post_data) do
            { title: 'A Title', body: 'A Body', post_status: 'public' }
          end

          it_behaves_like 'a successful post'

          it 'is not a draft post' do
            expect(actual).not_to be_draft
          end
        end # context 'public'
      end # context 'with post status set to'

      context 'with insufficient valid post data' do
        let(:post_data) { { body: 'A Body' } }

        message = 'Post data must include all required fields'
        it_behaves_like 'an unsuccessful post', :post, message
      end # context 'with insufficient valid post data'
    end # context 'with a Registered User as the current user'
  end # describe Actions::CreatePost
end # module Actions
