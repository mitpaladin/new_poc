
require 'spec_helper'

describe PostDao do
  describe 'supports initialisation' do
    it 'with no parameters' do
      expect { described_class.new }.not_to raise_error
    end

    it 'with a title parameter string only' do
      expect { FactoryGirl.create :post, body: nil }.not_to raise_error
    end

    it 'with all defined parameter values' do
      attribs = FactoryGirl.attributes_for :post, :image_post, :saved_post,
                                           :published_post
      expect { described_class.new attribs }.not_to raise_error
    end
  end # describe 'supports initialisation'

  describe 'reports validation correctly, showing that an instance' do
    let(:author_name) { 'Joe Palooka' }
    let(:title) { 'The Title' }

    describe 'is valid for an instance created with' do
      it 'an instance with an author name and a title' do
        subject = described_class.new author_name: author_name, title: title
        expect(subject).to be_valid
      end
    end # describe 'is valid for an instance created with'

    describe 'is invalid for an instance created with' do
      it 'no parameters' do
        expect(described_class.new).not_to be_valid
      end

      it 'a title but no author name' do
        expect(described_class.new title: title).not_to be_valid
      end

      it 'an author name but no title' do
        expect(described_class.new author_name: author_name).not_to be_valid
      end
    end # describe 'is invalid for an instance created with'
  end # describe 'reports validation correctly, showing that an instance'
end # describe PostDao
