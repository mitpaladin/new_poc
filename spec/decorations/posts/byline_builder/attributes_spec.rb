
require 'spec_helper'

describe Decorations::Posts::BylineBuilder::Attributes do
  before :each do
    Time.zone = 'Asia/Tokyo' # chosen arbitrarily
  end

  describe 'can be initialised with a' do
    after :each do
      expect { described_class.new @post }.not_to raise_error
    end

    it 'PostDao instance' do
      @post = FactoryGirl.build_stubbed :post
    end

    it 'Hash of attribute values, including at least :author_name' do
      @post = { author_name: 'Any User' }
    end
  end # describe 'can be initialised with a'

  describe 'has attribute readers for' do
    let(:published_attrs) { described_class.new published_source }
    let(:published_source) { FactoryGirl.attributes_for :post, :published_post }
    let(:unpublished_attrs) { described_class.new unpublished_source }
    let(:unpublished_source) { FactoryGirl.attributes_for :post }

    it 'author name' do
      source = FactoryGirl.attributes_for :post
      obj = described_class.new source
      expect(obj.author_name).to eq source[:author_name]
    end

    describe 'publication date, which' do
      it 'for a published post returns the publication date' do
        expect(published_attrs.pubdate).to be_within(0.5.seconds)
          .of published_source[:pubdate]
      end

      it 'for an unpublished post returns nil' do
        expect(unpublished_attrs.pubdate).to be nil
      end
    end # describe 'publication date, which'

    describe 'updated-at timestamp, which for an instance initialised with' do
      let(:basic_source) { FactoryGirl.attributes_for :post }
      let(:published_source) do
        basic_source.merge pubdate: Time.zone.parse(published_timestamp)
      end
      let(:published_timestamp) { '2015-05-12T09:15:24' }
      let(:updated_source) do
        basic_source.merge updated_at: Time.zone.parse(updated_timestamp)
      end
      let(:updated_timestamp) { '2015-05-13T18:50:46' }

      context 'an :updated_at attribute' do
        it 'returns the :updated_at timestamp value' do
          obj = described_class.new updated_source
          expect(obj.updated_at).to be_within(0.5.seconds)
            .of updated_source[:updated_at]
        end
      end # context 'an updated timestamp'

      context 'no :updated_at attribute but a publication-date attribute' do
        it 'returns the publication-date value' do
          obj = described_class.new published_source
          expect(obj.updated_at).to be_within(0.5.seconds)
            .of published_source[:pubdate]
        end
      end # context 'no :updated_at attribute but a publication-date attribute'

      context 'neither an :updated_at nor a publication_date attribute'
    end # describe 'updated-at timestamp, which for an instance initialised...'
  end # describe 'has attribute readers for'
end # describe Decorations::Posts::BylineBuilder::Attributes