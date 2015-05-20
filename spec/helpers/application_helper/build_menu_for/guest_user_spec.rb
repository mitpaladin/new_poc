
require 'spec_helper'

require 'application_helper/build_menu_for/guest_user'

describe ApplicationHelper::BuildMenuFor::GuestUser, type: :request do
  describe 'supports initialisation with' do
    it 'two parameters' do
      expected = /wrong number of arguments \(0 for 2\)/
      expect { described_class.new }.to raise_error ArgumentError, expected
    end

    it 'the first parameter being a view helper' do
      bogus = Object.new
      expect { described_class.new bogus, :navbar }.to raise_error do |e|
        expect(e).to be_a ParamContractError
        expected = 'Expected: (a value that responds to [:content_tag]),'
        expect(e.message).to match Regexp.escape(expected)
      end
    end

    it 'the second parameter being one of two valid symbols' do
      helper = Class.new do
        include ActionView::Helpers::TagHelper
      end.new
      expect { described_class.new helper, :navbar }.not_to raise_error
      expect { described_class.new helper, :sidebar }.not_to raise_error
      expect { described_class.new helper, :foobar }.to raise_error do |e|
        expect(e).to be_a ParamContractError
        expected = 'Expected: (navbar or sidebar)'
        expect(e.message).to match Regexp.escape(expected)
      end
      expect { described_class.new helper, 'navbar' }.to raise_error do |e|
        expect(e).to be_a ParamContractError
        expected = Regexp.escape '[:navbar, :sidebar]'
        actual = e.data[:contract].instance_values['vals']
        expect(actual.to_s).to match expected
      end
    end
  end # describe 'supports initialisation with'
end # describe ApplicationHelper::BuildMenuFor::GuestUser
