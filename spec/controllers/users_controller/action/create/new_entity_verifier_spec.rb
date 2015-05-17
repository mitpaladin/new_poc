
require 'spec_helper'

describe UsersController::Action::Create::NewEntityVerifier do
  let(:attributes) { FactoryGirl.attributes_for :user, :saved_user }
  let(:fake_repo) do
    success = user_exists?
    Class.new do
      def initialize(user_exists)
        @user_exists = user_exists
      end

      def find_by_slug(_slug)
        FancyOpenStruct.new(success?: @user_exists)
      end
    end.new(success)
  end
  let(:params) { { slug: slug, attributes: attributes, user_repo: fake_repo } }
  let(:slug) { attributes[:slug] }

  describe 'is initalised' do
    let(:user_exists?) { false }
    it 'successfully with parameters for :slug, :attributes, and :user_repo' do
      expect { described_class.new params }.not_to raise_error
    end
  end # describe 'is initialised'

  describe 'has a #verify method that' do
    describe 'succeeds when initial attribute hash has' do
      let(:user_exists?) { false }

      it 'slug for user that does not exist' do
        expect { described_class.new(params).verify }.not_to raise_error
      end
    end # describe 'succeeds when initial attribute hash has'

    describe 'raises an error when initial attribute hash has' do
      let(:user_exists?) { true }

      it 'a slug for a user that exists in the repository' do
        expect { described_class.new(params).verify }.to raise_error do |e|
          payload = YAML.load e.message
          expect(payload).to be_a Hash
          expect(payload[:messages].count).to eq 1
          expected = "A record identified by slug '#{attributes[:slug]}'" \
            ' already exists!'
          expect(payload[:messages].first).to eq expected
          expect(payload[:attributes]).to eq attributes
        end
      end
    end # describe 'raises an error when initial attribute hash has'
  end # describe 'has a #verify method that'
end # describe UsersController::Action::Create::NewEntityVerifier
