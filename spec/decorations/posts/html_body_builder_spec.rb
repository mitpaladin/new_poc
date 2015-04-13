
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
        converter = Newpoc::Services::MarkdownHtmlConverter.new
        expect { described_class.new converter }.not_to raise_error
      end
    end # describe 'can be initialised'

    it 'cannot be initialised with an invalid parameter' do
      expected = 'parameter must respond to the :to_html message'
      expect { described_class.new 'bogus' }.to raise_error ArgumentError,
                                                            expected
    end

    describe 'has a #build method that when called with a Post' do
      let(:obj) { described_class.new }

      context 'not containing an image URL' do
        let(:post) { FancyOpenStruct.new title: 'Post Title' }

        it 'wraps a simple string body in an HTML paragraph tag pair' do
          post.body = 'Simple Text'
          expected = ['<p>', '</p>'].join post.body
          expect(obj.build(post)).to eq expected
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
          url = 'http://www.example.com/image1.png'
          FancyOpenStruct.new title: 'Post Title', image_url: url
        end
      end # context 'containing an image URL'
    end # describe 'has a #build method that when called with a Post'
  end # describe Posts::HtmlBodyBuilder
end
