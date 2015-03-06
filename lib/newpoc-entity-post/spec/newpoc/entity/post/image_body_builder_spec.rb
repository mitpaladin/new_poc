
require 'spec_helper'

require 'newpoc/entity/post/image_body_builder'

# The `#body_markup` method requires and uses the MarkdownHtmlConverter service,
# which is now packaged separately from this component. That's fine, in the app
# and its specs...but unit tests at this level can't deal with that, because
# Rubygems' dependency mechanism expects dependencies to be in a gem repo,
# somewhere it can grab them from. That doesn't work with unbuilt dependencies.
def mock_body_markup_for(builder, caption, ret = caption.to_s)
  allow(builder).to receive(:body_markup).with(caption).and_return ret
end

module Newpoc
  module Entity
    class Post
      # *Private* support classes used by Post entity class.
      module SupportClasses
        describe ImageBodyBuilder do
          # ImageBodyBuilder now has an `#initialize` method taking a lambda
          # which is used to do the Markdown-to-HTML conversion. To use the
          # default (as in ordinary code), pass nothing, and the default will Do
          # The Right Thing. However, that default depends on a service that is
          # external to this unbuilt-dependency "Gem". Since that, too, is
          # packaged in the same way, mocking the conversion is the only way to
          # do unit tests. Ptui!
          let(:builder) { ImageBodyBuilder.new converter }
          let(:image_url) { 'http://www.example.com/image.png' }
          let(:caption) { 'This is a Caption' }
          let(:converter) do
            lambda do |markup|
              ['<div class="ib-mock">', markup, '</div>'].join
            end
          end

          describe '#build' do
            describe 'wraps its contents in an outermost tag that' do
              let(:obj) { OpenStruct.new image_url: image_url, body: caption }
              let(:fragment) { Nokogiri::HTML.fragment(builder.build obj) }
              # let(:elem) { fragment.children.first }
              let(:elem) do
                kids = fragment.children
                kids.first
              end

              before :each do
                mock_body_markup_for(builder, caption) unless @mocked
              end

              it 'is a "figure" element' do
                expect(elem.name).to eq 'figure'
              end

              it 'has two child elements' do
                expect(elem.children.length).to be 2
                elem.children.each { |child| expect(child).to be_element }
              end

              describe 'has a first child element that' do
                # Our mock is wrapping it in a div, remember?
                let(:child_element) { elem.children.first.children.first }

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
                  allow(builder).to receive(:body_markup).with(caption)
                    .and_return caption
                  expect(child_element.name).to eq 'figcaption'
                end

                it 'has the defined body as its inner text' do
                  # Stripped so that otherwise irrelevant newline does not break
                  # comparison
                  allow(builder).to receive(:body_markup).with(caption)
                    .and_return caption
                  expect(child_element.text.strip).to eq obj.body
                end
              end # describe 'has a second child element that'
            end # describe 'wraps its contents in an outermost tag that'

            describe 'when called with a missing post body' do
              let(:obj) { OpenStruct.new image_url: image_url }
              let(:fragment) { Nokogiri::HTML.fragment(builder.build obj) }
              let(:elem) { fragment.children.first }

              before :each do
                @mocked = true
                mock_body_markup_for(builder, nil)
              end

              it 'the "figcaption" is empty' do
                figcaption = elem.children[1]
                expect(figcaption.name).to eq 'figcaption'
                expect(figcaption.text).to be_empty
              end
            end # describe 'when called with a missing post body'
          end # describe :build
        end # describe ImageBodyBuilder
      end # module Newpoc::Entity::Post::SupportClasses
    end # class Newpoc::Entity::Post
  end # module Newpoc::Entity
end # module Newpoc
