
require 'spec_helper'

describe Decorations::Posts::HtmlBodyBuilder::ImagePostBuilder::Image do
  let(:doc) { Nokogiri::HTML::Document.new }
  let(:image_url) { 'http://example.com/image1.png' }
  let(:actual) { described_class.new(doc: doc, image_url: image_url).to_html }
  let(:outer_regex) { %r{\A<p>(<a .+>.+</a>)</p>\z} }

  describe 'returns HTML markup that' do
    it 'is a paragraph tag pair wrapping an anchor-tag pair' do
      expect(actual).to match outer_regex
    end

    describe 'includes an anchor tag with' do
      let(:anchor) { actual.match(outer_regex)[1] }

      it 'has the image URL as the "href" attribute' do
        expect(anchor).to match /.+ href="#{image_url}"/
      end

      it 'specifies a "target" attribute of "_blank"' do
        expect(anchor).to match /.+ target="_blank"/
      end
    end # describe 'includes an anchor tag with'

    describe 'includes an image tag as the child of the anchor tag with' do
      let(:image_tag) { actual.match(%r{<p><a.+>(<img .+>)</a></p>})[1] }

      it 'the image URL as the "src" attribute' do
        expect(image_tag).to match /.+ src="#{image_url}"/
      end

      it 'an explicit value of "max-width:100%;" for the "style" attribute' do
        expect(image_tag).to match /.+ style="max-width:100%;"/
      end
    end # describe 'includes an image tag as the child of the anchor tag with'
  end # describe 'returns HTML markup that'
end # describe Decorations::Posts::HtmlBodyBuilder::ImagePostBuilder::Image
