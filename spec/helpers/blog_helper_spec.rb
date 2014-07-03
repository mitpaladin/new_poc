require 'spec_helper'

require 'post_decorator'

require 'support/shared_examples/post_like_attributes'

describe BlogHelper do
  describe '#entries_for' do

    context 'without specifying a parameter' do

      context 'when no entries have been added to the blog' do

        it 'returns an empty array' do
          value = helper.entries_for
          expect(value).to be_an Array
          expect(value).to be_empty
        end
      end # context 'when no entries have been added to the blog'

      context 'when entries have been added to the blog' do
        before :each do
          FactoryGirl.create_list :post_datum, 10
          @entries = helper.entries_for
        end

        describe 'returns an array with' do

          it 'the correct number of entries' do
            expect(@entries).to be_an Array
            expect(@entries).to have(10).items
          end

          describe 'each item' do

            it_behaves_like 'Post-like attributes'

            it 'being a Post entity instance' do
              @entries.each { |entry| expect(entry).to be_a Post }
            end
          end # describe 'each item'
        end # describe 'returns an array with'
      end # context 'when entries have been added to the blog' do
    end # context 'without specifying a parameter' do

    context 'when specifying a parameter' do

      context 'when no entries have been added to the blog' do

        it 'returns an empty array' do
          blog = BlogData.first
          value = helper.entries_for blog
          expect(value).to be_an Array
          expect(value).to be_empty
        end
      end # context 'when no entries have been added to the blog'

      context 'when entries have been added to the blog' do
        before :each do
          FactoryGirl.create_list :post_datum, 10
          blog = BlogData.first
          @entries = helper.entries_for blog
        end

        describe 'returns an array with' do

          it 'the correct number of entries' do
            expect(@entries).to be_an Array
            expect(@entries).to have(10).items
          end

          describe 'each item' do

            it_behaves_like 'Post-like attributes'

            it 'being a Post entity instance' do
              @entries.each { |entry| expect(entry).to be_a Post }
            end

            it 'decorated with a PostDecorator' do
              @entries.each do |entry|
                expect(entry).to be_decorated_with(PostDecorator)
              end
            end
          end # describe 'each item'
        end # describe 'returns an array with'
      end # context 'when entries have been added to the blog' do
    end # context 'when specifying a parameter'
  end # describe '#entries_for'
end
