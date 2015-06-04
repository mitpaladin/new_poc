
require 'spec_helper'

describe Decorations::Posts::HtmlBodyBuilder::ImagePostBuilder::Figure do
  let(:actual) { described_class.new }

  it 'is initialised without parameters' do
    expect { described_class.new :bogus }.to raise_error do |e|
      expect(e).to be_a ParamContractError
      expect(e.message).to match %r{Expected: None,}
      expect(e.message).to match %r{Actual: :bogus}
    end
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
      described_class.new.tap do |figure|
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
  end # describe 'has a #to_html method that'

  describe 'has a #native method that' do
    let(:actual) do
      described_class.new.tap do |figure|
        figure.figcaption = dummy_figcaption
        figure.img = dummy_img
      end.native
    end
    let(:dummy_figcaption) { Ox::Element.new 'figcaption' }
    let(:dummy_img) { Ox::Element.new 'img' }

    it 'returns a single top-level Ox::Element instance' do
      expect(actual).to be_a Ox::Element
    end

    describe 'returns an element that has' do
      it 'a name of "figure"' do
        expect(actual.name).to eq 'figure'
      end

      it 'two child nodes' do
        expect(actual).to have(2).nodes
      end

      it 'an :img element as its first child node' do
        expect(actual.nodes.first.name).to eq 'img'
      end

      it 'a :figcaption element as its second child node' do
        expect(actual.nodes.last.name).to eq 'figcaption'
      end
    end # describe 'returns an element that has'
  end # describe 'has a #native method that'
end # describe Decorations::Posts::HtmlBodyBuilder::ImagePostBuilder::Figure
