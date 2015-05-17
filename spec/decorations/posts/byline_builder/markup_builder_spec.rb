
require 'spec_helper'

require_relative 'markup_builder/byline_markup_for'

describe Decorations::Posts::BylineBuilder::MarkupBuilder do
  let(:attr_class) { Decorations::Posts::BylineBuilder::Attributes }
  let(:published_attrs) { attr_class.new published_source }
  let(:published_source) { FactoryGirl.attributes_for :post, :published_post }
  let(:draft_attrs) { attr_class.new draft_source }
  let(:draft_source) { FactoryGirl.attributes_for :post }

  describe 'can be initialised with attributes for a' do
    it 'draft post' do
      expect { described_class.new draft_attrs }.not_to raise_error
    end

    it 'published post' do
      expect { described_class.new published_attrs }.not_to raise_error
    end
  end # describe 'can be initialised with attributes for a'

  describe 'has a #to_html method that, when initialised with a' do
    before :each do
      Time.zone = 'Asia/Singapore'
    end

    context "published post's attributes" do
      let(:obj) { described_class.new published_attrs }
      let(:markup) { obj.to_html }

      it_behaves_like 'byline markup for', 'Posted'
    end # context "published post's attributes"

    context "draft post's attributes" do
      let(:obj) { described_class.new draft_attrs }
      let(:markup) { obj.to_html }

      it_behaves_like 'byline markup for', 'Drafted'
    end # context "draft post's attributes"
  end # describe 'has a #to_html method that, when initialised with a'
end # describe Decorations::Posts::BylineBuilder::MarkupBuilder
