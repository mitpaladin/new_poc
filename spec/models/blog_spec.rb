
require 'spec_helper'

describe Blog do

  describe 'has accessors for' do

    before :each do
      @blog = Blog.new
    end

    describe 'a "title" that is' do

      it 'string-like' do
        expect(@blog.title).to respond_to :to_s
      end

      it 'not empty' do
        expect(@blog.title).to_not be_empty
      end
    end # describe 'a "title" that is'

    describe 'a "subtitle" that is' do

      it 'string-like' do
        expect(@blog.subtitle).to respond_to :to_s
      end

      it 'not empty' do
        expect(@blog.subtitle).to_not be_empty
      end
    end # describe 'a "subtitle" that is'

    describe 'an "entries" attribute that is' do

      it 'array-like Enumerable' do
        expect(@blog.entries).to respond_to :[]
        expect(@blog.entries).to be_an Enumerable
      end

      it 'initially empty' do
        expect(@blog.entries).to be_empty
      end
    end # describe 'an "entries" attribute that is'
  end # describe 'has accessors for'
end # describe Blog
