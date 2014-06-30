
require 'spec_helper'

# Module containing "boundary-layer objects" between DSOs and implementation.
module BLO
  describe BlogDataBoundary do
    describe 'has accessors for' do

      subject(:blog_data) { BlogDataBoundary.new }

      describe 'a "title" that is' do

        it 'string-like' do
          expect(blog_data.title).to respond_to :to_s
        end

        it 'not empty' do
          expect(blog_data.title).to_not be_empty
        end
      end # describe 'a "title" that is'

      describe 'a "subtitle" that is' do

        it 'string-like' do
          expect(blog_data.subtitle).to respond_to :to_s
        end

        it 'not empty' do
          expect(blog_data.subtitle).to_not be_empty
        end
      end # describe 'a "subtitle" that is'

      describe 'an "entries" collection that is' do

        it 'array-like' do
          expect(blog_data.entries).to respond_to :[]
        end

        it 'initially empty' do
          expect(blog_data.entries).to be_empty
        end
      end # describe 'an "entries" collection that is'
    end # describe 'has accessors for'
  end # describe BLO::BlogDataBoundary
end # module BLO
