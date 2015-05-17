
require 'spec_helper'

describe Decorations::Posts::HtmlBodyBuilder::ImagePostBuilder do
  describe 'can be initialised with' do
    let(:contract_expected) do
      /Expected: {:body_html=>String, :image_url=>String}/
    end

    it ':body_html and :image_url parameter strings' do
      expect { described_class.new body_html: '', image_url: '' }
        .not_to raise_error
      expect { described_class.new body_html: '' }.to raise_error do |e|
        expect(e).to be_a ParamContractError
        expect(e.message).to match(/Actual: {:body_html=>""}/)
        expect(e.message).to match(contract_expected)
      end
      expect { described_class.new image_url: '' }.to raise_error do |e|
        expect(e).to be_a ParamContractError
        expect(e.message).to match(/Actual: {:image_url=>""}/)
        expect(e.message).to match(contract_expected)
      end
    end
  end # describe 'can be initialised with'

  # More detailed spec coverage in the Figure, FigCaption and Image specs.
  describe 'has a #to_html method that' do
    let(:actual) { obj.to_html }
    let(:body_html) { 'BODY_HTML' }
    let(:image_url) { 'IMAGE_URL' }
    let(:obj) { described_class.new body_html: body_html, image_url: image_url }

    it 'is enclosed in a :figure tag pair' do
      expect(actual).to match /<figure>.+<\/figure>/
    end

    it 'contains the body HTML once' do
      expect(actual.split(body_html).count).to eq 2 # split once
    end

    it 'contains the image URL twice' do
      expect(actual.split(image_url).count).to eq 3 # split twice
    end
  end # describe 'has a #to_html method that'
end # describe Decoration::Posts::HtmlBodyBuilder::ImagePostBuilder
