
require 'spec_helper'

describe ApplicationHelper::AppwideFlashes do

  describe :show_appwide_flashes.to_s do

    it 'returns an empty string when passed an empty flash hash' do
      expect(helper.show_appwide_flashes PseudoFlash.new).to eq ''
    end

    describe 'for any single valid call' do

      before :each do
        @message = 'This is a notice'
        flashes = PseudoFlash.new
        flashes[:notice] = @message
        fragment = helper.show_appwide_flashes flashes
        @outer = Nokogiri::HTML::DocumentFragment.parse fragment
      end

      it 'generates a single outer element' do
        expect(@outer.children.length).to eq 1
      end

      describe 'generates an outer element that' do
        before :each do
          @element = @outer.children.first
        end

        it 'is a "div" element' do
          expect(@element).to be_element
          expect(@element.name).to eq 'div'
        end

        it 'has the .alert class' do
          expect(@element['class'].split).to include 'alert'
        end

        it 'has two children' do
          expect(@element.children.length).to eq 2
        end

        describe 'has as its first child node' do
          before :each do
            @child = @element.children.first
          end

          it 'a "button" element' do
            expect(@child).to be_element
            expect(@child.name).to eq 'button'
          end

          describe 'an element that' do
            it 'has the .close class' do
              expect(@child['class']).to eq 'close'
            end

            it 'has an aria-hidden attribute with the value "true"' do
              expect(@child['aria-hidden']).to eq 'true'
            end

            it 'has a data-dismiss attribute with the value "alert"' do
              expect(@child['data-dismiss']).to eq 'alert'
            end

            it 'has the "times" entity value as its text' do
              expected = Nokogiri::HTML::NamedCharacters.get('times').value
              expect(@child.text.codepoints.first).to eq expected
              expect(@child.text.length).to eq 1
            end
          end # describe 'an element that'
        end # describe 'has as its first child node'

        describe 'has as its second child node' do

          before :each do
            @node = @element.children.last
          end

          it 'a text node' do
            expect(@node.type).to eq Nokogiri::XML::Node::TEXT_NODE
          end

          it 'the correct text' do
            expect(@node.text).to eq @message
          end
        end # describe 'has as its second child node'

      end # describe 'generates an outer element that'

    end # describe 'for any single valid call'

    describe 'contains level-specific CSS for a single cell with level' do

      after :each do
        flash = PseudoFlash.new
        flash[@level] = @message
        fragment = helper.show_appwide_flashes flash
        outer = Nokogiri::HTML::DocumentFragment.parse fragment
        element = outer.children.first
        @expected_class = "alert-#{@level}" unless @expected_class
        expect(element['class']).to include @expected_class
      end

      it :notice do
        @level = :notice
        @message = 'This is a notice.'
      end

      it :success do
        @level = :success
        @message = 'It worked!'
      end

      it :error do
        @level = :error
        @message = 'Obviously a major malfunction.'
      end

      it :alert do
        @level = :alert
        @message = 'Be alert! The world needs more lerts!'
        @expected_class = 'alert-danger'
      end

    end # describe 'contains level-specific CSS for a single cell with level'

  end # describe :show_appwide_flashes

end

# "Test double" class for Rails' `ActionDispatch::Flash::FlashHash` class.
class PseudoFlash
  def initialize
    @flashes = {}
  end

  def []=(k, v)
    k = k.to_s
    @flashes[k] = v
  end

  def [](k)
    @flashes[k.to_s]
  end

  def empty?
    @flashes.empty?
  end

  def to_hash
    @flashes
  end
end
