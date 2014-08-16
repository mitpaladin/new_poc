
require 'spec_helper'

require 'blog_selector'

# Module containing "boundary-layer objects" between DSOs and implementation.
module BLO
  describe PostDataBoundary do
    let(:klass) { PostDataBoundary }

    describe :entry? do
      describe 'when there is no matching entry' do
        let(:entry) { FactoryGirl.build :post_datum }

        it 'returns false' do
          expect(klass.entry? entry).to be false
        end
      end # describe 'when there is no matching entry'

      describe 'when a matching entry exists' do
        let(:original) { FactoryGirl.create :post_datum }

        it 'returns true' do
          other = PostData.new title: original.title, body: original.body
          expect(klass.entry? other).to be true
        end
      end # describe 'when a matching entry exists'
    end # describe :entry?

    describe :full_error_messages do

      context 'for an entity with valid attributes' do
        let(:post) { Post.new FactoryGirl.attributes_for :post_datum }

        it 'returns an empty array' do
          expect(klass.full_error_messages post).to be_an Array
          expect(klass.full_error_messages post).to be_empty
        end
      end # context 'for an entity with valid attributes'

      context 'for an entry with a single invalid attribute' do
        let(:message) { "Title can't be blank" }
        let(:post) do
          Post.new FactoryGirl.attributes_for :post_datum, title: nil
        end

        it 'returns an array with a single error-message string' do
          expect(klass.full_error_messages post).to eq [message]
        end
      end # context 'for an entry with a single invalid attribute'

      context 'for an entry with multiple invalid attributes' do
        let(:messages) do
          [
            "Title can't be blank",
            "Author name can't be blank",
            'Body must be present if image URL is not present'
          ]
        end
        let(:post) { Post.new }

        it 'returns an array with one error message per invalid attribute' do
          actual = klass.full_error_messages post
          expect(actual.count).to eq messages.count
          actual.each do |item|
            expect(messages).to include item
          end
        end
      end # context 'for an entry with multiple invalid attributes'
    end # describe :full_error_messages

    describe :load_all do
      it 'returns an empty list when there are no entries' do
        expect(klass.load_all).to be_empty
      end

      describe 'when entries exist' do
        let(:entry_count) { 5 }
        let!(:_list) { FactoryGirl.create_list :post_datum, entry_count }

        it 'returns a list with the correct number of entries' do
          expect(klass.load_all).to have(entry_count).entries
        end
      end # describe 'when entries exist'
    end # describe :load_all

    describe :save_entry do

      describe 'when the entry is a new entry' do

        it 'increases the number of entries by one' do
          entry_count = klass.load_all.length
          post = FactoryGirl.build :post_datum
          klass.save_entry post
          new_length = klass.load_all.length
          expect(new_length).to eq entry_count + 1
        end
      end # describe 'when the entry is a new entry'

      describe 'when the entry already exists' do

        it 'keeps the number of entires unchanged' do
          post = FactoryGirl.create :post_datum
          entry_count = klass.load_all.length
          klass.save_entry post
          new_length = klass.load_all.length
          expect(new_length).to eq entry_count
        end
      end # describe 'when the entry already exists'
    end # describe :save_entry

    describe :valid? do

      context 'when called using a valid instance' do

        it 'returns true' do
          new_datum = FactoryGirl.create :post_datum
          post = klass.load_all.select { |p| p.title == new_datum.title }.first
          expect(klass.valid? post).to be true
        end
      end # context 'when called using a valid instance'

      context 'when called using an instance that is invalid' do

        let(:blog) { ::DSO::BlogSelector.run! }

        context 'because its title is invalid' do
          let(:post) do
            blog.new_post FactoryGirl.attributes_for(:post_datum, title: nil)
          end

          it 'returns false' do
            expect(klass.valid? post).to be false
          end
        end # context 'because its title is invalid'

        context 'because both its body and image url are empty' do
          let(:post) do
            blog.new_post FactoryGirl.attributes_for(:post_datum,
                                                     body: nil,
                                                     image_url: nil)
          end

          it 'returns false' do
            expect(klass.valid? post).to be false
          end
        end
      end # context 'when called using an instance that is invalid'
    end # describe :valid?
  end # describe BLO::PostDataBoundary
end # module BLO
