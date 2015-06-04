
require 'spec_helper'

describe Decorations::Posts::HtmlBodyBuilder::ImagePostBuilder::Image do
  let(:image_url) { 'http://example.com/image1.png' }

  describe 'supports initialisation with' do
    it 'a single required string parameter' do
      expect { described_class.new }.to raise_error ArgumentError, /0 for 1/
      # expect { described_class.new :anything }
    end
  end # describe 'supports initialisation with'

  describe 'has a #to_html method that returns' do
    let(:actual) { described_class.new(image_url).to_html }

    it 'an :img tag with a :src attribute with the correct URL' do
      expect(actual).to match %r{<img src="#{image_url}".*?/>}
    end
  end # describe 'has a #to_html method that returns'

  describe 'has a #native method that returns' do
    let(:actual) { described_class.new(image_url).native }

    it 'an Ox::Element instance' do
      expect(actual).to be_an Ox::Element
    end

    describe 'an instance with' do
      it 'the name "img"' do
        expect(actual.name).to eq 'img'
      end

      it 'no child nodes' do
        expect(actual).to have(0).nodes
      end

      it 'a single attribute, :src, with the image URL as its value' do
        expect(actual).to have(1).attribute
        expect(actual[:src]).to eq image_url
      end
    end # describe 'an instance with'
  end
end # describe Decorations::Posts::HtmlBodyBuilder::ImagePostBuilder::Image
