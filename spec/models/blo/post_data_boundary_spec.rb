
require 'spec_helper'

# Module containing "boundary-layer objects" between DSOs and implementation.
module BLO
  describe PostDataBoundary do
    describe :entry? do
      describe 'when there is no matching entry' do
        let(:entry) { FactoryGirl.build :post_datum }

        it 'returns false' do
          expect(PostDataBoundary.entry? entry).to be false
        end
      end # describe 'when there is no matching entry'

      describe 'when a matching entry exists' do
        let(:original) { FactoryGirl.create :post_datum }

        it 'returns true' do
          other = PostData.new title: original.title, body: original.body
          expect(PostDataBoundary.entry? other).to be true
        end
      end # describe 'when a matching entry exists'
    end # describe :entry?

    describe :load_all do
      it 'returns an empty list when there are no entries' do
        expect(PostDataBoundary.load_all).to be_empty
      end

      describe 'when entries exist' do
        let(:entry_count) { 5 }
        before :each do
          @created_list = FactoryGirl.create_list :post_datum, entry_count
        end

        it 'returns a list with the correct number of entries' do
          expected = @created_list.count
          expect(PostDataBoundary.load_all).to have(expected).entries
        end
      end # describe 'when entries exist'
    end # describe :load_all

    describe :save_entry do

      describe 'when the entry is a new entry' do

        it 'increases the number of entries by one' do
          entry_count = PostDataBoundary.load_all.length
          post = FactoryGirl.build :post_datum
          PostDataBoundary.save_entry post
          new_length = PostDataBoundary.load_all.length
          expect(new_length).to eq entry_count + 1
        end
      end # describe 'when the entry is a new entry'

      describe 'when the entry already exists' do

        it 'keeps the number of entires unchanged' do
          post = FactoryGirl.create :post_datum
          entry_count = PostDataBoundary.load_all.length
          PostDataBoundary.save_entry post
          new_length = PostDataBoundary.load_all.length
          expect(new_length).to eq entry_count
        end
      end # describe 'when the entry already exists'
    end # describe :save_entry
  end # describe BLO::PostDataBoundary
end # module BLO
