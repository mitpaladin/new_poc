
require 'spec_helper'

describe Decorations::Posts::HtmlBodyBuilder::ImagePostBuilder::Element do
  let(:doc) { Nokogiri::HTML::Document.new }
  let(:actual) { described_class.new doc }

  describe 'can be initialised with' do

    it 'a Nokogiri HTML document object' do
      expect { described_class.new doc }.not_to raise_error
    end
  end # describe 'can be initialised with'

  describe 'has a #to_html method that' do
    it 'fails with a must-override message' do
      expect { actual.to_html }.to raise_error do |e|
        expect(e.message).to eq 'Must override #to_html in a subclass'
      end
    end
  end # describe 'has a #to_html method that'

  describe 'has conceptually protected methods, including' do

    it 'an attribute-reader for the document object passed to #initialize' do
      expect(actual.doc).to eq doc
    end

    describe 'an #element method that returns' do
      let(:element) { actual.element element_name }
      let(:element_name) { 'foobar' }

      it 'a Nokogiri XML element' do
        expect(element).to be_a Nokogiri::XML::Element
      end

      it 'an element with the specified name' do
        expect(element.name).to eq element_name
      end
    end # describe 'an #element method that returns'

    it 'an #html_save_options method that returns the correct option bitmask' do
      expect(actual.html_save_options).to eq 70 # FIXME: document magic number
    end
  end # describe 'has conceptually protected methods, including'
end # describe Decorations::Posts::HtmlBodyBuilder::ImagePostBuilder::Element
