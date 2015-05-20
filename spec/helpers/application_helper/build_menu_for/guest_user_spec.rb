
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

  # NOTE: Validating markup can be done in one of two ways: by matching against
  # regexes or by parsing it with Ox, Nokogiri, et al, and walking the node tree
  # handed back. While regex matching is (purportedly) *conceptually* simpler,
  # it quickly devolves into esoteric, intricate hieroglyphs that require at
  # least as much effort to produce or decode as the code they're supposedly
  # helping to verify. No, thank you. Been there; done that; lived to tell.
  describe 'has a #markup method which' do
    let(:helper) do
      Class.new do
        include ActionView::Helpers
        include ActionView::Context
        include Rails.application.routes.url_helpers
      end.new
    end
    let(:obj) { described_class.new helper, :sidebar }
    let(:markup) { obj.markup }
    let(:outer_node) { Ox.parse obj.markup }

    describe 'returns HTML markup that' do
      it 'has an outermost :ul tag with "nav" and "nav-*" CSS classes' do
        expect(outer_node.value).to eq 'ul'
        expect(outer_node[:class]).to match(/nav nav-.+/)
      end

      describe 'has a :ul element which contains' do
        describe 'as its child node' do
          let(:list_item) { outer_node.nodes.first }
          let(:node) { list_item.nodes.first }

          it 'an :li element containing an :a element' do
            expect(list_item.value).to eq 'li'
            expect(list_item).to have(1).node
            expect(node.value).to eq 'a'
          end

          it 'a "Home" link to the root path' do
            expect(node.text).to eq 'Home'
            expect(node[:href]).to eq root_path
          end
        end # describe 'as its first child node'
      end # describe 'has a :ul element which contains'
    end # describe 'returns HTML markup that'
  end # describe 'has a #markup method which'
end # describe ApplicationHelper::BuildMenuFor::GuestUser
