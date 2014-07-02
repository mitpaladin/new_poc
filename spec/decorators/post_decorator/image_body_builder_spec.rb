
require 'spec_helper'
require 'nokogiri'

require 'post_decorator/image_body_builder'

class PostDecorator
  # Support class(es) for image post body builder.
  module SupportClasses
    describe ImageBodyBuilder do
      let(:builder) { ImageBodyBuilder.new h }
      let(:image_url) { 'http://www.example.com/image.png' }
      let(:caption) { 'This is a Caption' }

      describe :build do

        describe 'wraps its contents in an outermost tag tag is' do
          let(:obj) { OpenStruct.new image_url: image_url, body: caption }
          let(:fragment) { Nokogiri::HTML.fragment(builder.build obj) }
          let(:elem) { fragment.children.first }

          it 'a "figure" element' do
            expect(elem.name).to eq 'figure'
          end

          it 'has two child elements' do
            expect(elem.children.length).to be 2
            elem.children.each { |child| expect(child).to be_element }
          end

          describe 'has a first child element that' do
            let(:child_element) { elem.children.first }

            it 'is an "img" element' do
              expect(child_element.name).to eq 'img'
            end

            it 'has the defined image URL as its "src" attribute' do
              expect(child_element['src']).to eq obj.image_url
            end
          end # describe 'has a first child element that'

          describe 'has a second child element that' do
            let(:child_element) { elem.children[1] }

            it 'is a "figcaption" element' do
              expect(child_element.name).to eq 'figcaption'
            end

            it 'has the defined body as its inner text' do
              expect(child_element.text).to eq obj.body
            end
          end # describe 'has a second child element that'
        end # describe 'wraps its contents in an outermost tag tag is'

        describe 'when called with a missing post body' do
          let(:obj) { OpenStruct.new image_url: image_url }
          let(:fragment) { Nokogiri::HTML.fragment(builder.build obj) }
          let(:elem) { fragment.children.first }

          it 'the "figcaption" is empty' do
            figcaption = elem.children[1]
            expect(figcaption.name).to eq 'figcaption'
            expect(figcaption.text).to be_empty
          end
        end # describe 'when called with a missing post body'
      end # describe :build
    end # describe TextBodyBuilder
  end # module PostDecorator::SupportClasses
end # class PostDecorator
