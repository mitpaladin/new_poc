
require 'spec_helper'

# FIXME: Once `ox_builder.rb` is a uniquely-named file, kill this.
require_relative '../../app/services/ox_builder'

describe Services::OxBuilder do
  let(:obj) { described_class.new }
  let(:new_el) { described_class::ELEMENT_TYPE.new 'p' }

  describe 'supports initialisation with' do
    it 'no parameters' do
      expect { described_class.new }.not_to raise_error
      expect { described_class.new :bogus }.to raise_error do |e|
        expect(e).to be_a ParamContractError
        expect(e.message).to match Regexp.escape('Expected: None')
      end
    end
  end # describe 'supports initialisation with'

  describe 'has a #build instance method which' do
    it 'takes no parameters' do
      expect { obj.build :bogus }.to raise_error do |e|
        expect(e).to be_a ParamContractError
        expect(e.message).to match 'Expected: Proc'
      end
      proc = -> {}
      expect { obj.build proc }.to raise_error ArgumentError, /1 for 0/
    end

    it 'requires a block' do
      expect { obj.build }.to raise_error do |e|
        expect(e).to be_a ParamContractError
        expect(e.message).to match 'Expected: Proc'
      end
      el = new_el # must be in local/callable scope when nested block created
      expect { obj.build { el } }.not_to raise_error
    end

    it 'requires that that block return an Ox::Element instance' do
      el = new_el # must be in local/callable scope when nested block created
      expect { obj.build { el } }.not_to raise_error
    end

    it 'yields to that block in instance scope' do
      expect(obj.instance_variables).not_to include :@foo
      el = described_class::ELEMENT_TYPE.new 'p'
      obj.build do
        instance_variable_set :@foo, true
        el
      end
      expect(obj.instance_variable_get :@foo).to be true
    end
  end # describe 'has a #build instance method which'

  describe 'has a #doc instance method which' do
    it 'returns an Ox::Document instance' do
      expect(described_class.new.doc).to be_a Ox::Document
    end

    it 'repeatedly returns the same Ox::Document instance' do
      obj = described_class.new
      doc = obj.doc
      expect(obj.doc).to be doc
    end
  end # describe 'has a #doc instance method which'

  describe 'has a #dump instance method which' do
    it 'accepts anything and produces an XML-style string' do
      expect(obj.dump 42).to eq "<i>42</i>\n"
      expect(obj.dump :foo).to eq "<m>foo</m>\n"
      expect(obj.dump 'test').to eq "<s>test</s>\n"
      expect(obj.dump nil).to eq "<z/>\n"
      expect(obj.dump new_el).to eq "\n<p/>\n" # leading newline introduced
    end

    it 'correctly renders nested Ox elements' do
      input = '<p>This <em>is</em> a test.</p>'
      top_el = Ox.load input
      expected = "\n<p>This \n<em>is</em> a test.</p>\n"
      # NOTE: Do NOT simply call `Ox.dump` here; that will use default defaults.
      expect(obj.dump top_el).to eq expected
    end
  end # describe 'has a #dump instance method which'

  describe 'has an #element instance method which' do
    let(:elem) { obj.build { element('hr') } }
    it 'is not a public method' do
      expect { obj.element 'p' }.to raise_error NoMethodError, /private method/
    end

    it 'can of course be called from the block passed to #build' do
      expect(obj.dump elem).to eq "\n<hr/>\n"
    end

    it 'returns an Ox::Element instance' do
      expect(elem).to be_a Ox::Element
    end
  end # describe 'has an #element instance method which'
end # describe Services::OxBuilder
