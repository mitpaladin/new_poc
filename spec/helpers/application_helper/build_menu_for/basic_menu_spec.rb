
require 'spec_helper'

module ApplicationHelper
  # Module containing `ApplicationHelper#build_menu_for` and support classes.
  # The TestArticle *doesn't use* Contracts for its `#initialize` method; we
  # want to validate against those in the BasicMenu module.
  module BuildMenuFor
    class TestArticle
      include Contracts
      include BasicMenu

      def initialize(h, which)
        init_basic_menu h, which
      end

      Contract None => String
      def basic_markup
        build_container do
        end
      end

      Contract None => String
      def markup
        build_container do
          build_item_for 'Test Item 1', href: 'http://www.example.com/'
          build_separator_item
          build_item_for 'Test Item 2', href: 'http://www.example.com/'
        end
      end
    end # class ApplicationHelper::BuildMenuFor::TestArticle
  end
end

describe ApplicationHelper::BuildMenuFor::TestArticle, type: :request do
  let(:helper) do
    Class.new do
      include ActionView::Helpers
      include ActionView::Context
      include Rails.application.routes.url_helpers
    end.new
  end
  let(:obj) { described_class.new helper, which_menu }
  let(:which_menu) { :sidebar }

  before :each do
    Ox.default_options = { encoding: 'UTF-8' }
  end

  describe 'has an #init_basic_menu method that' do
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
  end # describe 'has an #init_basic_menu method that'

  describe 'has a #build_container method that' do
    let(:outer_node) { Ox.parse obj.basic_markup }

    describe 'must be called with' do
      it 'a block' do
        obj.class_eval do
          def invalid_call
            build_container
          end
        end
        expect { obj.invalid_call }.to raise_error do |e|
          expect(e).to be_a ParamContractError
          expect(e.message).to match(/Contract violation for argument 1 of 1/)
          expect(e.message).to match(/Expected: Proc/)
          expect(e.message).to match(/Actual: nil/)
          expected = 'Value guarded in: ApplicationHelper::BuildMenuFor::' \
            'BasicMenu::build_container'
          expect(e.message).to match Regexp.escape(expected)
        end
      end

      describe 'a block which may include calls to' do
        let(:outer_node) { Ox.parse obj.mini_markup }
        let(:list_item) { outer_node.locate('li[3]').first }

        describe '#build_separator_item, which' do
          before :each do
            obj.class_eval do
              def mini_markup
                build_container { build_separator_item }
              end
            end
          end

          it 'adds a fourth list item to the generated markup' do
            expect(list_item.value).to eq 'li'
          end

          it 'adds a list item containing an empty string' do
            expect(list_item.text).to be_blank
          end
        end # describe '#build_separator_item, which'

        describe '#build_item_for, which' do
          before :each do
            obj.class_eval do
              def mini_markup
                build_container { build_item_for 'item1', href: 'HREF' }
              end
            end
          end

          it 'adds a fourth list item to the generated markup' do
            expect(list_item.value).to eq 'li'
          end

          describe 'adds a list item containing an :a element that' do
            let(:anchor) { list_item.nodes.first }

            it 'has the correct link target' do
              expect(anchor.value).to eq 'a'
              expect(anchor[:href]).to eq 'HREF'
            end

            it 'has the correct link text' do
              expect(anchor.text).to eq 'item1'
            end
          end # describe 'adds a list item containing an :a element that'
        end # describe '#build_item_for, which'
      end # describe 'a block which may include calls to'
    end # describe 'must be called with'

    describe 'returns HTML markup that' do
      it 'has an outermost :ul tag with "nav" and "nav-*" CSS classes' do
        expect(outer_node.value).to eq 'ul'
        expect(outer_node[:class]).to match(/nav nav-.+/)
      end

      it 'contains three list items within the outermost :ul element' do
        expect(outer_node).to have(3).nodes
        outer_node.nodes.each { |li| expect(li.value).to eq 'li' }
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

      describe 'within its third list item, a text string that' do
        let(:list_item) { outer_node.locate('li[2]').first }

        it 'is blank' do
          expect(list_item.text).to be_blank
        end
      end # describe 'within its third list item, a text string that'
    end # describe 'returns HTML markup that' do
  end # describe 'has a #build_container method that'
end # describe ApplicationHelper::BuildMenuFor::TestArticle
