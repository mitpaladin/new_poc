
require 'spec_helper'

require 'posts/html_body_builder'

# POROs that act as presentational support for entities.
module Decorations
  describe Posts::HtmlBodyBuilder do
    describe 'can be initialised' do
      it 'without parameters' do
        expect { described_class.new }.not_to raise_error
      end

      it 'with a MarkdownHtmlConverter instance' do
        converter = MarkdownHtmlConverter.new
        expect { described_class.new converter }.not_to raise_error
      end
    end # describe 'can be initialised'

    it 'cannot be initialised with an invalid parameter' do
      expected = 'parameter must respond to the :to_html message'
      expect { described_class.new 'bogus' }.to raise_error do |e|
        expect(e).to be_a ParamContractError
        expect(e.data[:arg]).to eq 'bogus'
        expect(e.data[:contract].to_s).to eq 'MarkdownHtmlConverter or nil'
        expect(e.data[:arg_pos]).to eq 1
      end
    end

    describe 'has a #build method that when called with a Post' do
      let(:obj) { described_class.new }
      let(:actual) { obj.build post }

      context 'not containing an image URL' do
        let(:post) { FancyOpenStruct.new title: 'Post Title' }

        it 'wraps a simple string body in an HTML paragraph tag pair' do
          post.body = 'Simple Text'
          expected = ['<p>', '</p>'].join post.body
          expect(actual).to eq expected
        end

        it 'converts a body containing Markdown to HTML' do
          post.body = "This *is* a `test`.\n\n1. Foo;\n1. Bar.\n\nAll done."
          actual = obj.build post
          # Match the first paragraph.
          expected = %r{\A<p>This <em>is</em> a <code>test</code>.</p>}
          expect(actual).to match expected
          # Match the ordered list.
          expected = %r{<ol>\n<li>Foo;<\/li>\n<li>Bar.<\/li>\n<\/ol>}m
          expect(actual).to match expected
          # Why can't these be joined into a single regexp? Development and CI
          # disagree on newline placement, even with the (reported) same version
          # of Nokogiri. Pfffft.
        end
      end # context 'not containing an image URL'

      context 'containing an image URL' do
        let(:post) do
          body = 'Default `Post` Body Text'
          url = 'http://www.example.com/image1.png'
          FancyOpenStruct.new title: 'Post Title', image_url: url, body: body
        end

        it 'returns markup enclosed in a :figure tag pair' do
          expected = %r{\A<figure>(.*)</figure>\z}m
          expect(actual).to match expected
        end

        describe 'returns markup enclosed in a :figure tag pair, with' do
          it 'the first child of the :figure being an :a tag pair' do
            expected = %r{<figure><p><a .+>.+?</a></p><figcaption>}
            expect(actual).to match(expected)
          end

          describe 'the :a tag pair' do
            let(:enclosed) do
              actual.match(%r{<figure><p>(<a .+>.+?</a>)</p><figcaption>})[1]
            end

            it 'has the post image URL as its "href" attribute' do
              expect(enclosed).to match(/.+ href="#{post.image_url}" .+/)
            end

            it 'encloses an :img tag whose "src" is the post image URL' do
              inner = /<a .+><img src="#{post.image_url}" .+><\/a>/
              expect(enclosed).to match inner
            end
          end # describe 'the :a tag pair'

          it 'a :figcaption tag pair as the last child of the :figure' do
            expected = %r{\A<figure>.+<figcaption>(.+)</figcaption></figure>\z}m
            converter = MarkdownHtmlConverter.new
            caption = converter.to_html post.body
            expect(actual).to match(expected)
            expect(actual.match(expected).captures.first).to eq caption
          end
        end # describe 'returns markup enclosed in a :figure tag pair, with'
      end # context 'containing an image URL'
    end # describe 'has a #build method that when called with a Post'
  end # describe Posts::HtmlBodyBuilder
end
