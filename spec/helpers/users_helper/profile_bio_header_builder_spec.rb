
require 'spec_helper'

require 'current_user_identity'

describe ProfileBioHeaderBuilder, type: :request do
  let(:helper) do
    Class.new do
      include ActionView::Helpers::TextHelper
      include ActionView::Context
      include Rails.application.routes.url_helpers
      attr_reader :session
      def initialize(*)
        @session = {}
        self
      end
    end.new
  end

  describe 'supports initialisation with' do
    it 'two required parameters' do
      expect { described_class.new }.to raise_error ArgumentError, /0 for 2/
    end

    it 'the first of two parameters being an (unchecked) user-name string' do
      expect { described_class.new 'anything', helper }.not_to raise_error
    end

    it 'the second of two parameters being a Rails view-helper instance' do
      expect { described_class.new 'anything', 'oops' }.to raise_error do |e|
        expect(e).to be_a ParamContractError
        expect(e.message).to match(/Actual: "oops"/)
        expected = 'Expected: ' \
          '(a value that responds to [:concat, :content_tag, :session]),'
        expect(e.message).to match Regexp.escape(expected)
      end
    end
  end # describe 'supports initialisation with'

  describe 'supports a #to_html instance method that' do
    context 'when called while no user is logged in' do
      let(:actual) { obj.to_html }
      let(:obj) { described_class.new user_name, helper }
      let(:user_name) { 'Thaddeus Q Bostwick-Huddle LXVI' }

      it 'returns an HTML string' do
        expect(actual).to be_a String
        expect { Ox.parse actual }.not_to raise_error
      end

      describe 'returns an HTML string that' do
        let(:parsed) { Ox.parse actual }

        it 'is enclosed by an :h1 tag pair with the CSS class "bio"' do
          expect(parsed.value).to eq 'h1'
          expect(parsed[:class]).to eq 'bio'
        end

        it 'has correct enclosed text, including the specified user name' do
          h1 = parsed.nodes.first
          expect(h1).to eq 'Profile Page for ' + user_name
        end
      end # context 'when called while no user is logged in'
    end # context 'when called while no user is logged in'

    context 'when called while the target user is logged in' do
      let(:actual) { obj.to_html }
      let(:obj) { described_class.new user.name, helper }
      let(:user) { FactoryGirl.create :user, :saved_user }
      let(:identity) { CurrentUserIdentity.new helper.session }

      before :each do
        identity.current_user = user
      end

      it 'returns an HTML string' do
        expect(actual).to be_a String
        expect { Ox.parse actual }.not_to raise_error
      end

      describe 'containing an :a tag pair at the end of the content that' do
        let(:button) { Ox.parse(actual).nodes.last }

        it 'is the second of two nodes in the returned HTML' do
          expect(Ox.parse actual).to have(2).nodes
        end

        it 'is an :a tag' do
          expect(button.value).to eq 'a'
        end

        it 'has the correct CSS styles' do
          expect(button[:class]).to eq 'btn btn-xs pull-right'
        end

        it 'has the correct "button" caption text' do
          expect(button.text).to eq 'Edit Your Profile'
        end
      end # describe 'containing an :a tag pair at the end of the content...'
    end # context 'when called while the target user is logged in'

    context 'when called while a user other than the target is logged in' do
      let(:actual) { obj.to_html }
      let(:obj) { described_class.new user.name, helper }
      let(:other_user) { FactoryGirl.create :user, :saved_user }
      let(:user) { FactoryGirl.create :user, :saved_user }
      let(:identity) { CurrentUserIdentity.new helper.session }

      before :each do
        identity.current_user = other_user
      end

      it 'returns an HTML string' do
        expect(actual).to be_a String
        expect { Ox.parse actual }.not_to raise_error
      end

      it 'does not include a button-styled :a tag pair' do
        parsed = Ox.parse(actual)
        expect(parsed.nodes.count).to eq 1
        expect(parsed.nodes.first).to be_a String # NOT a node-like thing.
      end
    end # context 'when called while a user other than the target is logged in'
  end # describe 'supports a #to_html instance method that'
end
