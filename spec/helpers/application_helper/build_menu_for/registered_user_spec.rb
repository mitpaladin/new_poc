
require 'spec_helper'

require 'application_helper/build_menu_for/registered_user'

describe ApplicationHelper::BuildMenuFor::RegisteredUser, type: :request do
  let(:current_user) { FancyOpenStruct.new name: 'Some User' }
  before :each do
    Ox.default_options = { encoding: 'UTF-8' }
  end

  describe 'supports initialisation with' do
    let(:helper) do
      Class.new do
        include ActionView::Helpers::TagHelper
      end.new
    end
    let(:u) { current_user } # keep lines short
    it 'three parameters' do
      expected = /wrong number of arguments \(0 for 3\)/
      expect { described_class.new }.to raise_error ArgumentError, expected
    end

    it 'the first parameter being a view helper' do
      bogus = Object.new
      expect { described_class.new bogus, :navbar, u }.to raise_error do |e|
        expect(e).to be_a ParamContractError
        expected = 'Expected: (a value that responds to [:content_tag]),'
        expect(e.message).to match Regexp.escape(expected)
      end
    end

    it 'the second parameter being one of two valid symbols' do
      expect { described_class.new helper, :navbar, u }.not_to raise_error
      expect { described_class.new helper, :sidebar, u }.not_to raise_error
      expect { described_class.new helper, :foobar, u }.to raise_error do |e|
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

    it 'the third parameter being an object that responds to :name' do
      expect { described_class.new helper, :navbar, u }.not_to raise_error
      u = Object.new
      expect { described_class.new helper, :navbar, u }.to raise_error do |e|
        expect(e).to be_a ParamContractError
        expect(e.message).to match(/Contract violation for argument 3 of 3:/)
        expected = Regexp.escape 'Expected: (a value that responds to [:name])'
        expect(e.message).to match expected
      end
    end
  end # describe 'supports initialisation with'

  describe 'has a #markup method which' do
    let(:helper) do
      Class.new do
        include ActionView::Helpers
        include ActionView::Context
        include Rails.application.routes.url_helpers
      end.new
    end
    let(:obj) { described_class.new helper, :sidebar, current_user }
    let(:markup) { obj.markup }
    let(:outer_node) { Ox.parse obj.markup }

    describe 'returns HTML markup that' do
      it 'has an outermost :ul tag with "nav" and "nav-*" CSS classes' do
        expect(outer_node.value).to eq 'ul'
        expect(outer_node[:class]).to match(/nav nav-.+/)
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

        it 'has the text "New Post"' do
          expect(anchor.text).to eq 'New Post'
        end

        it 'links to the new-post path' do
          expect(anchor[:href]).to eq new_post_path
        end
      end # describe 'within its fourth list item, an :a element that'

      describe 'within its fifth list item, an :a element that' do
        let(:list_item) { outer_node.locate('li').last }
        let(:anchor) { list_item.locate('a').first }

        it 'has the "data-method" attribute value of "delete"' do
          expect(anchor['data-method']).to eq 'delete'
        end

        it 'has the "rel" value of "nofollow"' do
          expect(anchor['rel']).to eq 'nofollow'
        end

        it 'has the text "Log out"' do
          expect(anchor.text).to eq 'Log out'
        end

        it 'links to the current-session path' do
          expect(anchor[:href]).to eq session_path('current')
        end
      end # describe 'within its fifth list item, an :a element that'
    end # describe 'returns HTML markup that'
  end # describe 'has a #markup method which'
end # describe ApplicationHelper::BuildMenuFor::RegisteredUser
