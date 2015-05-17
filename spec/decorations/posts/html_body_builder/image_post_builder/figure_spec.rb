
require 'spec_helper'

describe Decorations::Posts::HtmlBodyBuilder::ImagePostBuilder::Figure do
  let(:doc) { Nokogiri::HTML::Document.new }
  let(:actual) { described_class.new doc }

  it 'is initialised using a Nokogiri::HTML::Document instance' do
    expect { described_class.new }.to raise_error ArgumentError, /0 for 1/
    expect { described_class.new doc }.not_to raise_error
  end

  describe 'attribute' do
    it 'readers are not supported' do
      expect(actual).not_to respond_to :figcaption
      expect(actual).not_to respond_to :img
    end

    describe 'writers are supported for' do

      it ':figcaption' do
        expect { actual.figcaption = '' }.not_to raise_error
      end

      it ':img' do
        expect { actual.img = '' }.not_to raise_error
      end
    end # describe 'writers are supported for'
  end # describe 'attribute'

  describe 'has a #to_html method that' do
    let(:actual) do
      described_class.new(doc).tap do |figure|
        figure.figcaption = dummy_figcaption
        figure.img = dummy_img
      end
    end
    let(:dummy_figcaption) { 'FIGCAPTION__FIGCAPTION' }
    let(:dummy_img) { 'IMG__IMG' }

    it 'wraps its output in a :figure tag pair' do
      expect(actual.to_html).to match /<figure>(.+)<\/figure>/
    end

    desc = 'contains the specified figure content, immediately followed by ' \
      'the specified figcaption content'
    it desc do
      parts = ['<figure>', dummy_img, dummy_figcaption, '</figure>']
      expect(actual.to_html).to eq parts.join
    end
  end
end # describe Decorations::Posts::HtmlBodyBuilder::ImagePostBuilder::Figure
