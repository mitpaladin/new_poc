
require 'spec_helper'

describe Decorations::Posts::HtmlBodyBuilder::ImagePostBuilder::FigCaption do
  let(:doc) { Nokogiri::HTML::Document.new }
  let(:dummy_caption) { 'a caption' }
  let(:tag_pair) { ['<figcaption><p>', '</p></figcaption>'] }

  describe 'can be initialised with' do
    it 'a single parameter' do
      expect { described_class.new }.to raise_error ArgumentError, /0 for 1/
    end

    it 'a single string parameter' do
      expect { described_class.new :oops }.to raise_error do |e|
        expect(e).to be_a ParamContractError
        expect(e.message).to match /Expected: String,/
        expect(e.message).to match /Actual: :oops/
      end
    end
  end # describe 'can be initialised with'

  describe 'has a #to_html method that returns' do
    let(:actual) { described_class.new(dummy_caption).to_html }

    it 'a :figcaption tag pair' do
      expect(actual).to match %r{^<figcaption>.+</figcaption>$}
    end

    describe 'correctly-rendered content when supplied as' do
      after :each do
        expect(described_class.new(@caption).to_html).to eq @expected
      end

      it 'text' do
        @caption = 'This is a caption.'
        @expected = tag_pair.join @caption
      end

      it 'HTML' do
        content = 'This <em>is</em> a caption.'
        @caption = ['<p>','</p>'].join content
        @expected = tag_pair.join content
      end

      it 'Markdown' do
        @caption = 'This **is** a caption.'
        @expected = tag_pair.join 'This <strong>is</strong> a caption.'
      end
    end # describe 'correctly-rendered content when supplied as'
  end # describe 'has a #to_html method that returns'

  describe 'has a #native method that returns' do
    let(:actual) { described_class.new(dummy_caption).native }

    it 'an Ox::Element instance' do
      expect(actual).to be_a Ox::Element
    end

    it 'an instance whose name is "figcaption"' do
      expect(actual.name).to eq 'figcaption'
    end

    it 'the correct content as its single child node' do
      expect(actual).to have(1).node
      expect(Ox.dump actual.nodes.first).to match %r{<p>#{dummy_caption}</p>}
    end
  end # describe 'has a #native method that returns'
end # describe Decorations::Posts::HtmlBodyBuilder::ImagePostBuilder::FigCaption
