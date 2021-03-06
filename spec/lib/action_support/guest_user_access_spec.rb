
require 'spec_helper'

require 'action_support/guest_user_access'

describe ActionSupport::GuestUserAccess do
  describe 'has initialisation that' do
    it 'requires one parameter that responds to :name' do
      message = 'wrong number of arguments (0 for 1..2)'
      expect { described_class.new }.to raise_error ArgumentError, message
      param = FancyOpenStruct.new name: 'testing'
      expect { described_class.new param }.not_to raise_error
    end

    it 'accepts a second, optional parameter as a String' do
      param = FancyOpenStruct.new name: 'foo'
      expect { described_class.new param, 'bar' }.not_to raise_error
    end
  end # describe 'has initialisation that'

  context 'when initialised using only the current_user parameter, it' do
    let(:obj) { described_class.new current_user }

    describe 'has a #verify method that, when initialised with' do
      context 'the Guest User' do
        let(:current_user) { FancyOpenStruct.new name: 'Guest User' }

        it 'returns itself' do
          expect(obj.verify).to be obj
        end
      end # context 'the Guest User'

      context 'a user other than the Guest User' do
        let(:current_user) { FancyOpenStruct.new name: 'Just Anybody' }

        it 'raises an error with the correct message' do
          expected_data = {
            messages: ["Already logged in as #{current_user.name}!"]
          }
          message = YAML.dump expected_data
          expect { obj.verify }.to raise_error do |e|
            expect(e.message).to eq message
          end
        end
      end # context 'a user other than the Guest User'
    end # describe 'has a #verify method that, when initialised with'

    describe 'has a #prohibit method that, when initialised with' do
      context 'the Guest User' do
        let(:current_user) { FancyOpenStruct.new name: 'Guest User' }

        it 'raises an error with the correct message' do
          expected_data = {
            messages: ['Not logged in as a registered user!']
          }
          message = YAML.dump expected_data
          expect { obj.prohibit }.to raise_error do |e|
            expect(e.message).to eq message
          end
        end
      end # context 'the Guest User'

      context 'a user other than the Guest User' do
        let(:current_user) { FancyOpenStruct.new name: 'Just Anybody' }

        it 'returns itself' do
          expect(obj.prohibit).to be obj
        end
      end # context 'a user other than the Guest User'
    end # describe 'has a #prohibit method that, when initialised with'
  end #  context 'when initialised using only the current_user parameter, it'

  desc = 'when initialised using a string as the second #initialize param, it'
  context desc do
    let(:guest_user_name) { 'Unregistered' }
    let(:guest_user) { FancyOpenStruct.new name: guest_user_name }
    let(:default_guest_user) { FancyOpenStruct.new name: 'Guest User' }
    let(:new_guest_obj) { described_class.new guest_user, guest_user_name }
    let(:default_guest_obj) do
      described_class.new default_guest_user, guest_user_name
    end

    describe 'uses that string as the Guest User name and' do
      it 'verifies a current user with that name as being the Guest User' do
        expect(new_guest_obj.verify).to be new_guest_obj
      end

      it 'prohibits a current user with that name when #prohibit is called' do
        expect { new_guest_obj.prohibit }.to raise_error
      end

      message = 'rejects a current user with the default guest name as the' \
        ' Guest User'
      it message do
        expect { default_guest_obj.verify }.to raise_error
      end

      message = 'does not prohibit a current user with the default guest name' \
        ' when #prohibit is called'
      it message do
        expect { default_guest_obj.prohibit }.not_to raise_error
      end
    end # describe 'uses that string as the Guest User name and'
  end # context 'when initialised using a string as the second ... param, it'
end # describe ActionSupport::GuestUserAccess
