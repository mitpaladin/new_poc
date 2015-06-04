
require 'spec_helper'

shared_examples 'the message for a user of type' do |user_type|
  user_name = if user_type == 'Guest User'
                user_type
              else
                'J Random User'
              end

  context "for a #{user_type}" do
    it 'includes the correct greeting text in the markup' do
      user = FancyOpenStruct.new name: user_name
      el = Ox.parse method.call(user)
      expect(el.text).to eq "Hello, #{user.name}!"
    end
  end # context "for a #{user_type}"
end # shared_examples 'the message for a user of type'

describe ApplicationHelper::BuildGreeterFor do
  describe :build_greeter_for.to_s do
    subject(:method) { public_method :build_greeter_for }

    it 'takes a single parameter' do
      expect(method.arity.abs).to be 1
    end

    it 'raises when called with a parameter that does not respond to :name' do
      expect { method.call Object.new }.to raise_error do |e|
        expect(e).to be_a ParamContractError
        expected = Regexp.escape 'Expected: (a value that responds to [:name])'
        expect(e.message).to match expected
      end
    end

    context 'for either a Guest or Registered User' do
      let(:user) { FancyOpenStruct.new name: 'Just Anybody' }

      describe 'returns the correct markup, comprising' do
        let(:markup) do
          Ox.parse method.call(user)
        end

        it 'a div' do
          expect(markup.name).to eq 'div'
        end

        describe 'a div with the correct' do
          it 'CSS classes' do
            expected = 'greeter navbar-text navbar-right'.split
            actual = markup['class'].split
            expected.each { |css_class| expect(actual).to include css_class }
            expect(actual).to have(expected.count).items
          end
        end # describe 'a div with the correct'
      end # describe 'returns the correct markup, comprising'
    end # context 'for either a Guest or Registered User'

    it_behaves_like 'the message for a user of type', 'Guest User'

    it_behaves_like 'the message for a user of type', 'Registered User'
  end # describe build_greeter_for
end # describe ApplicationHelper::BuildGreeterFor
