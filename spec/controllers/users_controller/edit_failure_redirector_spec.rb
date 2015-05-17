
require 'spec_helper'

describe UsersController::EditFailureRedirector do
  let(:fake_controller) do
    Class.new do
      attr_reader :redirects, :root_url_calls

      def initialize
        @redirects = []
        @root_url_calls = []
      end

      def redirect_to(*args)
        @redirects.push args
        # don't care about faking a return value here
      end

      def root_url(*args)
        @root_url_calls.push args
        root_url_literal
      end

      def root_url_literal
        'http://localhost/'
      end
    end.new
  end

  describe 'has initialisation that' do
    it 'requires two keyword parameters, :payload and :helper' do
      message = /missing keywords: payload, helper/
      expect { described_class.new }.to raise_error ArgumentError, message
    end
  end # describe 'has initialisation that'

  describe 'has a #go method that' do
    describe 'when initialised with a :payload that' do
      context 'has a :not_user key in its Hash, it' do
        let(:obj) do
          described_class.new payload: payload, helper: fake_controller
        end
        let(:payload) { { not_user: 'some user' } }

        before :each do
          obj.go
        end

        describe 'redirects' do
          let(:redirects) { fake_controller.redirects }

          it 'once' do
            expect(fake_controller).to have(1).redirect
          end

          it 'to the root URL' do
            expect(redirects.first[0]).to eq fake_controller.root_url_literal
          end

          it 'with the not-logged-in error message as a flash alert' do
            flash = redirects.first[1][:flash]
            expect(flash).to respond_to :to_hash
            expect(flash).to have_key :alert
            expect(flash[:alert]).to eq 'Not logged in as some user!'
          end
        end # describe 'redirects'

        it 'calls the #root_url helper method once' do
          expect(fake_controller).to have(1).root_url_call
        end
      end # context 'has a :not_user key in its Hash, it'
    end # describe 'when initialised with a :payload that'
  end # describe 'has a #go method that'
end # describe UsersController::EditFailureRedirector
