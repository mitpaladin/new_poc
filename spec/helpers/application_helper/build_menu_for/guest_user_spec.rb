
require 'spec_helper'

require 'application_helper/build_menu_for/guest_user'

describe ApplicationHelper::BuildMenuFor::GuestUser, type: :request do
  before :each do
    Ox.default_options = { encoding: 'UTF-8' }
  end

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

      describe 'has an outermost :ul element which contains' do
        it 'five :li child nodes, and no other nodes' do
          expect(outer_node).to have(5).nodes
          expect(outer_node.locate 'li').to eq outer_node.nodes
        end

        describe 'within its first list item, an :a element that' do
          let(:list_item) { outer_node.locate('li[0]').first }
          let(:anchor) { list_item.locate('a').first }

          it 'has the text "Home"' do
            expect(anchor.text).to eq 'Home'
          end

          it 'links to the root path' do
            expect(anchor[:href]).to eq root_path
          end
        end # describe 'within its first list item, an :a element that'

        describe 'within its second list item, an :a element that' do
          let(:list_item) { outer_node.locate('li[1]').first }
          let(:anchor) { list_item.locate('a').first }

          it 'has the text "All members"' do
            expect(anchor.text).to eq 'All members'
          end

          it 'links to the users path' do
            expect(anchor[:href]).to eq users_path
          end
        end # describe 'within its second list item, an :a element that'

        describe 'within its third list item, a string that' do
          let(:list_item) { outer_node.locate('li[2]').first }
          let(:content) { list_item.nodes.first }

          it 'is a nonbreaking space' do
            expected = [0xA0]
            expect(content.codepoints).to eq expected
          end
        end # describe 'within its third list item, a string that'

        describe 'within its fourth list item, an :a element that' do
          let(:list_item) { outer_node.locate('li[3]').first }
          let(:anchor) { list_item.locate('a').first }

          it 'has the text "Sign up"' do
            expect(anchor.text).to eq 'Sign up'
          end

          it 'links to the new-user path' do
            expect(anchor[:href]).to eq new_user_path
          end
        end # describe 'within its fourth list item, an :a element that'

        describe 'within its fifth list item, an :a element that' do
          let(:list_item) { outer_node.locate('li').last }
          let(:anchor) { list_item.locate('a').first }

          it 'has the text "Log in"' do
            expect(anchor.text).to eq 'Log in'
          end

          it 'links to the new-session path' do
            expect(anchor[:href]).to eq new_session_path
          end
        end # describe 'within its fifth list item, an :a element that'
      end # describe 'has an outermost :ul element which contains' do
    end # describe 'returns HTML markup that'
  end # describe 'has a #markup method which'
end # describe ApplicationHelper::BuildMenuFor::GuestUser
