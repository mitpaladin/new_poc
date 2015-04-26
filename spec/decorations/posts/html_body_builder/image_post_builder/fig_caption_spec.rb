
require 'spec_helper'

describe Decorations::Posts::HtmlBodyBuilder::ImagePostBuilder::FigCaption do
  let(:doc) { Nokogiri::HTML::Document.new }
  let(:tag_pair) { ['<figcaption><p>', '</p></figcaption>'] }
  let(:text_caption) { 'This is a caption.' }
  let(:html_caption) { '<p>This <em>is</em> a caption.</p>' }
  let(:markdown_caption) { 'This **is** a caption.' }

  describe 'has a #to_html method that correctly builds a figcaption from' do
    after :each do
      obj = described_class.new doc: doc, content: @caption
      expect(obj.to_html).to eq @expected
    end

    it 'text' do
      @caption = text_caption
      @expected = tag_pair.join 'This is a caption.'
    end

    it 'HTML' do
      @caption = html_caption
      @expected = tag_pair.join 'This <em>is</em> a caption.'
    end

    it 'Markdown' do
      @caption = markdown_caption
      @expected = tag_pair.join 'This <strong>is</strong> a caption.'
    end
  end # describe 'has a #to_html method that correctly builds a figcaption from'
end # describe Decorations::Posts::HtmlBodyBuilder::ImagePostBuilder::FigCaption
