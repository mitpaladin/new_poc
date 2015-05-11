
require 'spec_helper'

describe UsersController::Action::Edit::CurrentUserEntityMatcher do
  describe 'can be initialised with' do
    it 'any two object instances responding to the :name message' do
      current_user = FancyOpenStruct.new name: 'anything'
      entity = FancyOpenStruct.new name: 'at all'
      test_code = lambda do
        described_class.new current_user: current_user, entity: entity
      end
      expect { test_code.call }.not_to raise_error
    end
  end # describe 'can be initialised with'

  describe 'has a #match method which' do
    let(:obj) { described_class.new current_user: current_user, entity: entity }
    let(:entity) { FancyOpenStruct.new name: 'Some User' }

    context 'when initialised with matching values' do
      let(:current_user) { FancyOpenStruct.new name: entity.name }

      it 'does not raise an error' do
        expect { obj.match }.not_to raise_error
      end

      it 'returns its own same object instance' do
        expect(obj.match).to be obj
      end
    end # context 'when initialised with matching values'

    context 'when initialised with differing values' do
      let(:current_user) { FancyOpenStruct.new name: 'Another Name' }

      it 'raises an error' do
        expect { obj.match }.to raise_error RuntimeError
      end

      describe 'raises an error with' do
        it 'a JSON-formatted Hash as its message string' do
          expect { obj.match }.to raise_error do |e|
            expect(JSON.parse e.message).to be_a Hash
          end
        end

        describe 'a JSON-formatted Hash as its message string, containing' do
          let(:payload) do
            begin
              obj.match
            rescue RuntimeError => e
              JSON.parse e.message
            end
          end

          it 'a "not_user" key with the original user name as its value' do
            expect(payload['not_user']).to eq entity.name
          end

          it 'a "current" key with the current user name as its value' do
            expect(payload['current']).to eq current_user.name
          end
        end # describe 'a JSON-formatted Hash as its message string, containing'
      end # describe 'raises an error with'
    end # context 'when initialised with differing values'
  end # describe 'has a #match method which'
end # describe UsersController::Action::Edit::CurrentUserEntityMatcher
