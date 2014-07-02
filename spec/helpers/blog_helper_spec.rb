require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the BlogHelper. For example:
#
# describe BlogHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
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

            it 'being a Post entity instance' do
              @entries.each { |entry| expect(entry).to be_a Post }
            end

            describe 'having the correct' do

              it 'title' do
                expr = /Test Title Number \d+/
                @entries.each { |entry| expect(entry.title).to match expr }
              end

              it 'body text' do
                @entries.each { |entry| expect(entry.body).to eq 'The Body' }
              end

              it 'image URL' do
                url = 'http://example.com/image1.png'
                @entries.each { |entry| expect(entry.image_url).to match url }
              end
            end # describe 'having the correct'
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

            it 'being a Post entity instance' do
              @entries.each { |entry| expect(entry).to be_a Post }
            end

            describe 'having the correct' do

              it 'title' do
                expr = /Test Title Number \d+/
                @entries.each { |entry| expect(entry.title).to match expr }
              end

              it 'body text' do
                @entries.each { |entry| expect(entry.body).to eq 'The Body' }
              end

              it 'image URL' do
                url = 'http://example.com/image1.png'
                @entries.each { |entry| expect(entry.image_url).to match url }
              end
            end # describe 'having the correct'
          end # describe 'each item'
        end # describe 'returns an array with'
      end # context 'when entries have been added to the blog' do
    end # context 'when specifying a parameter'
  end # describe '#entries_for'
end
