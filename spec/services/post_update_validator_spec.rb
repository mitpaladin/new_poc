
require 'spec_helper'

describe PostUpdateValidator do
  let(:klass) { PostUpdateValidator }

  describe :initialize.to_s do
    it 'requires one or two parameters' do
      message = 'wrong number of arguments (0 for 1..2)'
      expect { klass.new }.to raise_error ArgumentError, message
    end

    describe 'accepts for the first parameter' do
      after :each do
        expect { klass.new @post, {} }.not_to raise_error
      end

      it 'a PostData instance' do
        @post = FactoryGirl.build :post_datum
      end

      it 'a FancyOpenStruct with all needed fields' do
        @post = FancyOpenStruct.new FactoryGirl.attributes_for(:post_datum)
      end

      describe 'a Hash with all needed fields with keys as' do

        it 'symbols' do
          @post = FactoryGirl.attributes_for :post_datum
        end

        it 'strings' do
          @post = {}
          p = FactoryGirl.attributes_for :post_datum
          p.keys.each { |k| @post[k.to_s] = p[k] }
        end
      end # describe 'a Hash with all needed fields with keys as'
    end # describe 'accepts for the first parameter'

    describe 'accepts for the second parameter' do
      after :each do
        post = FactoryGirl.build :post_datum
        expect { klass.new post, @data }.not_to raise_error
      end

      it 'a PostData instance' do
        @data = FactoryGirl.build :post_datum
      end

      it 'a FancyOpenStruct with all needed fields' do
        @data = FancyOpenStruct.new FactoryGirl.attributes_for(:post_datum)
      end

      it 'a Hash with all needed fields' do
        @data = FactoryGirl.attributes_for :post_datum
      end
    end # describe 'accepts for the second parameter'
  end # describe :initialize

  describe :valid? do
    context 'when initialised with a valid post' do
      let(:post) { FactoryGirl.build :post_datum }

      describe 'returns "true" for' do
        after :each do
          expect(klass.new post, @data).to be_valid
        end

        it 'an empty "data" Hash' do
          @data = {}
        end

        describe 'a Hash with acceptable values for' do

          it 'title' do
            @data = { title: 'A New Title' }
          end

          it 'author name' do
            @data = { author_name: 'Somebody Else Entirely' }
          end
        end # describe 'a Hash with acceptable values for'
        it 'a Hash with acceptable values' do
          @data = { body: 'Updated body text goes here.' }
        end

        it 'a FancyOpenStruct with acceptable values' do
          @data = FancyOpenStruct.new body: 'Updated body text goes here.'
        end
      end # describe 'returns "true" for'

      describe 'returns "false" for' do
        after :each do
          expect(klass.new post, @data).not_to be_valid
        end

        it 'a :data Hash with empty body text and image URL' do
          @data = { body: '', image_url: '' }
        end

        it 'a :data FancyOpenStruct with empty body text and image URL' do
          @data = FancyOpenStruct.new body: '', image_url: ''
        end

        describe 'data with' do
          it 'an empty title' do
            @data = { title: '' }
          end

          it 'nil for an author name' do
            @data = { author_name: nil }
          end
        end # describe 'data with'
      end # describe 'returns "false" for'
    end # context 'when initialised with a valid post'
  end # describe :valid?

  describe :messages.to_s do
    let(:post) { FactoryGirl.build :post_datum }

    it 'is always empty unless :valid? has been called' do
      data = { title: '' }
      obj = klass.new post, data
      expect(obj.messages).to be_empty
      expect(obj).not_to be_valid
      expect(obj.messages).to have(1).message
    end

    context 'when there are no errors' do
      let(:data) { { body: 'Updated Body Content' } }
      let(:obj) { klass.new post, data }

      it 'returns an empty hash' do
        expect(obj.messages).to eq obj.messages.to_h
        expect(obj.messages).to be_empty
      end
    end # context 'when there are no errors'

    context 'when a single field has an error' do
      let(:data) { { title: '' } }
      let(:obj) { klass.new post, data }

      it 'returns a Hash with a single item' do
        expect(obj).not_to be_valid
        expect(obj.messages).to have_key :title
        expect(obj.messages[:title]).to eq 'Title must be present'
      end
    end # context 'when a single field has an error'

    context 'when multiple fields have errors' do
      let(:data) { { body: '', image_url: nil } }
      let(:obj) { klass.new post, data }

      it 'returns a Hash with one item for each invalid field' do
        expect(obj).not_to be_valid
        expect(obj.messages.keys).to eq [:body, :image_url]
        message = 'Body must be present if image url is missing or blank'
        expect(obj.messages[:body]).to eq message
        message = 'Image url must be present if body is missing or blank'
        expect(obj.messages[:image_url]).to eq message
      end
    end # context 'when multiple fields have errors'
  end # describe :messages
end # describe PostUpdateValidator
