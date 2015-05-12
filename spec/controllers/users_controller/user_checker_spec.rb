
require 'spec_helper'

describe UsersController::CreateFailure::UserChecker do
  describe 'can be initialised with' do
    it 'two required parameters' do
      expect { described_class.new }.to raise_error ArgumentError, /0 for 2/
    end

    describe 'two required parameters, where' do
      it 'the first is a YAML-encoded string' do
        expr = /no implicit conversion of nil into String/
        expect { described_class.new nil, nil }.to raise_error TypeError, expr
        # OK, it needs to be a String
        expect { described_class.new 'foo', nil }.to raise_error do |e|
          expr = /undefined method `each' for "foo":String/
          expect(e.message).to match expr
        end
        # OK; it can't be a simple string; it contains a sequense. JSON or YAML?
        arg1 = YAML.dump(foo: 'bar')
        expect { described_class.new arg1, nil }.not_to raise_error
      end
    end # describe 'two required parameters, where'
  end # describe 'can be initialised with'

  describe 'has a #parse method that' do
    let(:obj) { described_class.new param_str, :unused_legacy_parameter }
    let(:attributes) { FactoryGirl.attributes_for :user }
    let(:messages) { [] }
    let(:param_str) { YAML.dump params }
    let(:params) { { messages: messages } }
    let(:result) { obj.parse }

    it 'returns nil if no attributes were specified in the initaliser Hash' do
      expect(result).to be nil
    end

    describe 'if attributes were specified' do
      let(:params) { { attributes: attributes, messages: messages } }

      context 'but the messages array was empty' do
        it 'returns a user entity' do
          expect(result).to be_a UserFactory.entity_class
        end

        it 'returns a user that is not the Guest User' do
          expect(result.name).not_to eq UserFactory.guest_user.name
        end

        it 'returns a valid user' do
          expect(result).to be_valid
        end
      end # context 'but the messages array was empty'

      describe 'and the messages array includes a report that' do
        after :each do
          messages.push "#{@message}"
          expect(result).to be_a UserFactory.entity_class
          expected = 'is invalid: ' + @message
          expect(result.errors[error_field]).to include expected
        end

        describe 'the name' do
          let(:error_field) { :name }

          it "can't be blank" do
            @message = "Name can't be blank"
          end

          it 'is too short' do
            @message = 'Name is too short (minimum is 6 characters)'
          end

          it 'already exists' do
            @message = 'is invalid: A record identified by slug' \
              " '#{attributes[:name]}' already exists!"
          end
        end # describe 'the name'

        describe 'the password' do
          let(:error_field) { :password }

          it 'is too short' do
            @message = 'Password must be longer than 7 characters'
          end

          it 'must match the password confirmation' do
            @message = 'Password must match the password confirmation'
          end
        end # describe 'the password'
      end # describe 'and the messages array includes a report that'
    end # describe 'if attributes were specified'
  end # describe 'has a #parse method that'
end # describe UsersController::CreateFailure::UserChecker
