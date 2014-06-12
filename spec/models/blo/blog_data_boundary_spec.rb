
require 'spec_helper'

# Module containing "boundary-layer objects" between DSOs and implementation.
module BLO
  describe BlogDataBoundary do
    subject(:blog_data) { BlogDataBoundary.new }

    describe 'has accessors for' do

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
    end # describe 'has accessors for'
  end # describe BLO::BlogDataBoundary
end # module BLO
