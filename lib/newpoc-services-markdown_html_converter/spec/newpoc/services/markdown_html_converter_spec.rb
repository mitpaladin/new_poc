
require 'spec_helper'

require 'newpoc/services/markdown_html_converter'

require_relative 'support/fcb_data'
require_relative 'support/table_data'

def make_emoji(emoji, unicode)
  path = "/images/emoji/unicode/#{unicode}.png"
  %(<img class="emoji" title="#{emoji}" alt="#{emoji}" src="#{path}") \
    ' height="20" width="20" align="absmiddle">'
end

def make_mention(name, base = 'https://github.com')
  %(<a href="#{base}/#{name}" class="user-mention">@#{name}</a>)
end

def maxwidth_image_link_for(path)
  img = %(<img src="#{path}" style="max-width:100%;">)
  %(<a href="#{path}" target="_blank">#{img}</a>)
end

module Newpoc
  # Services available to different Newpoc components.
  module Services
    describe MarkdownHtmlConverter do
      it 'can be constructed' do
        expect(described_class.new).to be_a MarkdownHtmlConverter
        # ...and not raise an error, naturally...
      end

      describe 'correctly parses markup including' do
        after :each do
          actual = described_class.new.to_html @markup
          if @expected.respond_to? :named_captures # it's a Regexp
            expect(actual).to match(@expected)
          else # better be a String
            expect(actual.gsub("\n", '')).to eq @expected.to_s.gsub("\n", '')
          end
        end

        it 'autolinks' do
          @markup = 'Visit http://www.example.com/ and see for yourself!'
          @expected = '<p>Visit <a href="http://www.example.com/">' \
            'http://www.example.com/</a> and see for yourself!</p>' \
            "\n"
        end

        it 'fenced code blocks' do
          @markup = FCBData.markup
          @expected = FCBData.expected
        end

        # Highlight supported by RedCarpet, not by HTML::Pipeline. Someone
        # *could* eventually get around to writing a new filter for it. Someday.
        # it 'highlight' do
        #   @markup = 'This is ==highlighted== and this is not.'
        #   @expected = '<p>This is <mark>highlighted</mark> and this is not.' \
        #     "</p>\n"
        # end

        # Not supported by the github-markdown Gem used by HTML::Pipeline.
        # See https://help.github.com/articles/github-flavored-markdown/ for
        # more.
        # it 'no_intra_emphasis' do
        #   @markup = 'This has a snake_case_style string in it.'
        #   @expected = '<p>This has a snake<u>case</u>style string in it.' \
        #     "</p>\n"
        # end

        # Not supported by the github-markdown Gem used by HTML::Pipeline. Use
        # the `<del></del>` HTML tag pair per the doc at
        # https://github.com/github/markup/tree/master#html-sanitization
        # it 'strikethrough' do
        #   @markup = 'This is ~~hideous~~excellent'
        #   @expected = '<p>This is <del>hideous</del>excellent</p>' "\n"
        # end

        # Not supported by the github-markdown Gem used by HTML::Pipeline. Use
        # the `<sup></sup>` HTML tag pair per the doc at
        # https://github.com/github/markup/tree/master#html-sanitization
        # it 'superscript' do
        #   @markup = 'At script^super and after'
        #   @expected = '<p>At script<sup>super</sup> and after</p>' "\n"
        # end

        it 'tables' do
          @markup = TableData.markup
          @expected = TableData.expected
        end

        it 'emphasised (underlined)' do
          @markup = 'This is *emphasised*.'
          @expected = '<p>This is <em>emphasised</em>.</p>'
        end

        # Following are supported by HTML::Pipeline but not by RedCarpet as
        # shipped.

        it 'emoji' do
          @markup = 'This is great! :expressionless:'
          emoji = make_emoji ':expressionless:', '1f611'
          @expected = '<p>This is great! ' + emoji + '</p>'
        end

        it '@mentions' do
          @markup = 'Pinging @jdickey. Does it work?'
          @expected = "<p>Pinging #{make_mention 'jdickey'}. Does it work?</p>"
        end

        describe 'image max width' do
          it 'leaves surrounding markup intact' do
            caption = '<figcaption><p>Foo</p></figcaption>'
            @markup = %(<figure><img src="foo.png">#{caption}</figure>)
            image_link = maxwidth_image_link_for 'foo.png'
            @expected = %(<figure>#{image_link}#{caption}</figure>)
          end

          it 'makes no change when image is within an anchor tag' do
            @markup = '[image](/foo.png)'
            @expected = %(<p><a href="/foo.png">image</a></p>)
          end

          it 'sets other images to max-width of 100% in a new tab' do
            @markup = '<img src="foo.png">'
            @expected = ['<p>', '</p>'].join maxwidth_image_link_for('foo.png')
          end
        end # describe 'image max width'
      end # describe 'correctly parses markup including'
    end # describe Newpoc::Services::MarkdownHtmlConverter
  end # module Newpoc::Services
end # module Newpoc
