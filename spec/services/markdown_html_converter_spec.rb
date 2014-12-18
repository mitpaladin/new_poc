
require 'spec_helper'

require_relative 'support/fcb_data'
require_relative 'support/table_data'

describe MarkdownHtmlConverter do
  it 'can be constructed' do
    expect(described_class.new).to be_a MarkdownHtmlConverter
    # ...and not raise an error, naturally...
  end

  describe 'correctly parses markup including' do

    after :each do
      expect(described_class.new.to_html @markup).to eq @expected
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

    it 'highlight' do
      @markup = 'This is ==highlighted== and this is not.'
      @expected = '<p>This is <mark>highlighted</mark> and this is not.</p>' \
          "\n"
    end

    it 'no_intra_emphasis' do
      @markup = 'This has a snake_case_style string in it.'
      @expected = '<p>This has a snake<u>case</u>style string in it.</p>' "\n"
    end

    it 'strikethrough' do
      @markup = 'This is ~~hideous~~excellent'
      @expected = '<p>This is <del>hideous</del>excellent</p>' "\n"
    end

    it 'superscript' do
      @markup = 'At script^super and after'
      @expected = '<p>At script<sup>super</sup> and after</p>' "\n"
    end

    it 'tables' do
      @markup = TableData.markup
      @expected = TableData.expected
    end

    it 'underline' do
      @markup = 'This may be _underlined_ but this is still *emphasised*.'
      @expected = '<p>This may be <u>underlined</u> but this is still ' \
          "<em>emphasised</em>.</p>\n"
    end
  end # describe 'correctly parses markup including'
end # describe MarkdownHtmlConverter
